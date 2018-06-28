# Continuous Aggregation

Continuous Aggregation is the act of taking a continuous collection, or any other ObservableCollection, for that matter, and continuously updating a scalar value that is some kind of aggregation of that collection. For example, let's say you have a collection of Customers and you want to have a value on your WPF GUI that is a constantly updating number showing the sum of the customer ages. It could also be more complicated and show the sum total of all orders purchased by a subset of customers. The possibilities are endless.

The first thing you would do is create your continuous collection, potentially by using a CLINQ query over an observable collection, as shown below:
{{
customersOverThirty = from cust in AllCustomers
                        where cust.Age > 30
                        select cust;
}}

Then you create your continuous value object and invoke one of the aggregation extensions, such as ContinuousSum:
{{
ContinuousValue<int> totalAge = customersOverThirty.ContinuousSum<Customer>(c => c.Age);
}}

If you want to get really fancy, you can even nest/chain continuous aggregations together, as shown here:
{{
ContinuousValue<double> totalPrice = customersOverThirty.ContinuousSum<Customer>(
    c => c.Orders.ContinuousSum<Order>( o => o.Price ));
}}

Now you can safely place this continuous value in your model object, a model singleton, or the datacontext of a WPF window and the WPF GUI will automatically be made aware of the changes to that scalar value!

Click here to see how you can [Create Your Own Continuous Aggregate](Create-Your-Own-Continuous-Aggregate).

Continuous Aggregation should be available in the 1.1.0.0 release - [release:12569](release_12569)