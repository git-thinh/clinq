# Adding to a Source Collection from a Collection Changed Event Handler
Suppose that you are building an application where you are monitoring changes to a source collection. You define a filter result set using CLINQ. In response to a change in the filter set, you eventually want to add a new row to the source collection. The problem is that you cannot modify the contents of a collection during the CollectionChanged event handler for _very good_, obvious reasons.

Here's a hypothetical and, very real, scenario. You have a source collection that represents the contents of a shopping cart. You create a CLINQ query that contains the contents of the shopping cart where the SKU matches certain specific "magic SKUs". 
A Magic SKU is often a signal indicator that something else needs to be done to a shopping cart. 
This is often how electronic coupons, discounts, gift certificates, and other credits are redeemed.

Here is some code to build such a cart and such a monitoring query:
{{
_sourceCart = new ContinuousCollection<OrderItem>();

_sourceCart.CollectionChanged += 
    new NotifyCollectionChangedEventHandler(_sourceCart_CollectionChanged);

_sourceCart.Add(
    new OrderItem()
    {
        Quantity = 1,
        SKU = "101392031",
        Price = 19.99,
        Description = "Cool DVD"
    });

var modCart = from orderItem in _sourceCart
              where orderItem.SKU == "999999999"
              select orderItem;

modCart.CollectionChanged += 
    new NotifyCollectionChangedEventHandler(modCart_CollectionChanged);

_sourceCart.Add(
    new OrderItem()
    {
        Quantity = 1,
        SKU = "999999999",
        Price = 19.99,
        Description = "Awesome DVD" 
    });
}}

In this code, you see a two item cart and then a monitor query designed to contain just the items with the SKU of all 9s. In a real-world scenario, the monitor query might be far more complex, looking for the presence of 2 DVDs in a given price range or 1 DVD plus 1 DVD player etc. Such monitor queries are also used to scan for potential up-sell and cross-sell opportunities for in-cart advertising and suggesting.

Here is the code that listens to changes in the monitor query and responds by adding a discount to the cart: (note, this code **WILL** throw an exception!)
{{
  if (e.Action == NotifyCollectionChangedAction.Add)
            {               
              // customer added the magic DVD to the cart
              // give them a $20 discount!
             OrderItem discount = new OrderItem()
                    {
                        Quantity = 1,
                        SKU = "-1",
                        Price = -20.00,
                        Description = "Buy the cool and awesome DVDs and get one free!"
                    };

              _sourceCart.Add(discount);

            }
}}

To get around the limitation of running into the re-entry barrier that is part of ObservableCollection, all you really need to do is use a background thread to perform the addition. Notification of the background-added item will actually be posted to the right Dispatcher, so the GUI will still know about it when bound:
{{
if (e.Action == NotifyCollectionChangedAction.Add)
{               
        // customer added the magic DVD to the cart
        // give them a $20 discount!
    Thread t = new Thread(
        new ThreadStart(delegate()
    {
        OrderItem discount = new OrderItem()
        {
            Quantity = 1,
            SKU = "-1",
            Price = -20.00,
            Description = "Buy the cool and awesome DVDs and get one free!"
        };
        
        _sourceCart.Add(discount);

    }));
    t.Start();
}
}}