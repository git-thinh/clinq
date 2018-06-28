**Project Description**
Continous LINQ is a .NET Framework 3.5 extension that builds on the LINQ query syntax to create continuous, self-updating result sets. 
In traditional LINQ queries, you write your query and get stale results. With Continuous LINQ, 

you write a query and the results of that query are continuously updated as changes are made to the source collection or items within the source collection. 

CLINQ has tremendous value in GUI development and is especially useful in binding to filtered streams of data such as financial or other network message data.

**[Getting Started](Getting-Started)**
* [Hello World - CLINQ Style](Hello-World---CLINQ-Style)
* [How CLINQ Works](How-CLINQ-Works)
* [Sample Usage Scenarios](Sample-Usage-Scenarios)
* [Continuous Aggregation](Continuous-Aggregation)

**Reactive Programming**
* [ReactiveObject](http://kutruff.wordpress.com/2009/07/14/reactive-programming-in-c-reactiveobject/) NOTE: **You must now also call OnPropertyChanging in addition to OnPropertyChanged when using ReactiveObject**

**[Feature Roadmap](Feature-Roadmap)** - What we're thinking of adding to CLINQ in the future

**Advanced Scenarios**
* [Adding to a Source Collection from a Collection Changed Event Handler](Adding-to-a-Source-Collection-from-a-Collection-Changed-Event-Handler)

**Appendix and Reference**
* [CLINQ FAQ](CLINQ-FAQ)
* [Supported LINQ Syntax](Supported-LINQ-Syntax)
* [Supported Platforms](Supported-Platforms)
* [Andy Kutruff's Blog](http://kutruff.wordpress.com)
* [.NET Addict's CLINQ Blog Posts](http://dotnetaddict.dotnetdevelopersjournal.com/tags/?/clinq)

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