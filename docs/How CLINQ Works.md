# How CLINQ Works

Before discussing how Continuous LINQ is possible, we should take a quick look at how LINQ is possible. LINQ queries are made possible through some syntactic magic that was put into the .NET Framework v3.5.  
Keywords such as **where**, **select**, **from**, **orderby**, and **groupby** are converted from "natural" query syntax, which is the SQL-like syntax that most of us are familiar with, 
into function calls that make extensive use of lambdas and language extensions to add these methods to objects of type _IEnumerable<T>_, etc.

For example, the following natural syntax LINQ query:
{{
    var q = from cust in rawData.Customers
                where cust.Age > 21
                orderby cust.Name
                select cust;
}}

will be re-written in language extension syntax by the compiler to look more like this:
{{
    var q = rawData.Customers.Where( cust => cust.Age > 21).OrderBy( cust => cust.Name ).Select ( row => row );
}}

# Extending LINQ with Language Extensions

If you want to inject your own code into the query pipeline that operates on objects of a particular type, then all you really need to do is implement your own language extensions on that type, _provided those extensions match the signatures of the default LINQ extensions_.

The goal of Continuous LINQ is to ride on top of the normal LINQ queries. Whenever you issue a LINQ query against a special type (e.g. a ContinuousCollection), 
CLINQ will inject listeners into the source that will propagate applicable changes to the output result set. 
This is what allows you to write a query against a list of customers that only contains customers over age 21 that _continuously updates itself_ when customers are added to and removed from the original source query, as well as when the age of customers is modified.

Here is an example of one of the many language extensions that drives CLINQ. 
This is an extension that adds a **Where** method on an input collection wrapper used for CLINQ housekeeping (it wraps ObservableCollection<T> instances).
Note how a new CLINQ collection is created for the output and a **FilteringViewAdapter<T>** is attached to the input. 
This behavior that we call _adapter chaining_ is key to allowing CLINQ to function properly.

{{
 private static ContinuousCollection<T> Where<T>(
            InputCollectionWrapper<T> source, Func<T, bool> filterFunc) where T : INotifyPropertyChanged
        {
            Trace.WriteLine("Filtering Observable Collection.");
            ContinuousCollection<T> output = new ContinuousCollection<T>();
            new FilteringViewAdapter<T>(source, output, filterFunc);

            return output;            
        }
}}

When more than one LINQ query segment exists, the output from one method call is passed as the input to the next language extension in line.
For example, in the following query:

{{
    var q = from order in rawData.Orders
          where order.Price > 500.00
          orderby order.VendorID desc
}}

Two adapters will be created. The **Where** method will be invoked, which will attach a **FilterViewAdapter<T>** to the source collection.
The output of that (which is dynamically updated by the FilterViewAdapter<T> in response to source events) will be passed as the input to the **OrderBy** method.
The **OrderBy** method will attach a **SortingViewAdapter<T>** to the input (which is the output of the filter, remember), and produce another CLINQ collection
as output.
This adapter chaining gives us nearly infinite flexibility and allows virtually any standard LINQ query to become continuous just by virtue of having the CLINQ namespace in scope or by querying directly against a ContinuousCollection<T>.