# Hello World - CLINQ Style

Before rigging CLINQ queries up to a data bound GUI such as WPF, it is often helpful to write a very simple use case tester just to see the technology in action.
To start, create a new Console application and reference the **ContinuousLinq** Assembly that you downloaded from the latest release or that you built on your own using Visual Studio 2008.
In this sample, build a Customer class that looks like the one below:

{{
public class Customer : INotifyPropertyChanged
{
    private int _age;
    private string _name;

    public int Age
    {
      get { return _age; }
      set
      {
        _age = value;
        NotifyChanged("Age");
      }
    }

    public string Name
    {
      get { return _name; }
      set
      {
        _name = value;
        NotifyChanged("Name");
      }
    }

    private void NotifyChanged(string propName)
    {
        if (PropertyChanged != null)
            PropertyChanged(this, new PropertyChangedEventArgs(propName));
    }

    public event PropertyChangedEventHandler PropertyChanged;
}

}}

Once you have your customer class built, you can create a ContinuousCollection to hold the source list and you can then create a query to hold all Customers of legal drinking age (for this sample, that's 21):

{{
    ContinuousCollection<Customer> _source = new ContinuousCollection<Customer>();
    ContinuousCollection<Customer> _legalDrinkers = from cust in _source
                                                                              where cust.Age >= 21
                                                                              select cust;
}}

Note that defining the second query didn't require any items to be in the source collection, which is part of the benefit of using CLINQ. Now you can attach to the CollectionChanged event handler of the **_legalDrinkers** collection so you can watch when items are added:

{{
    _legalDrinkers.CollectionChanged += 
         new System.Collections.Specialized.NotifyCollectionChangedEventHandler(legalDrinkers_CollectionChanged);
}}

And your event handler:

{{
static void legalDrinkers_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
{
    if (e.Action == NotifyCollectionChangedAction.Add)
    {
        Console.WriteLine("Item Added.");
    }            
}
}}

At this point you have a source collection and you also have a ContinuousCollection result set that will continuously update itself when items are added to the source.
To see this in action, add the following few lines of code to the end of your **Main** method:

{{
    _source.Add( new Customer() { Name = "Bob", Age = 20 });
    _source.Add( new Customer() { Name = "Al", Age = 23 });
}}

When you run this application, **_legalDrinkers** will receive a collection changed event fire notification when **Al** is added to the source but not when **Bob** is added. This illustrates the continuous nature of CLINQ and how you can declaratively define dynamic, streaming views of data.

The last test that you want to do in order to make sure that CLINQ is functioning properly is to increase someone's age and make sure that the modified
customer is then added to the output collection automatically. To do this, add the following line of code to your project:

{{
    _source[0](0).Age = 35; // Bob grew up!
}}

Now you should receive two collection changed event firings for the output collection. 
The first one for when Al is added to the source with a sufficient age to qualify for membership in the output collection, 
and the second for when Bob is modified to subsequently pass the predicate condition on the output collection.

More detailed samples are available in the downloads section for each release.

For more information on how CLINQ works, check out this Wiki page: [How CLINQ Works](How-CLINQ-Works)