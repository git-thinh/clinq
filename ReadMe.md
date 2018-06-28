# CLINQ Supported Platforms

Currently CLINQ has been tested to work on the following platforms:

* Full .NET Framework 3.5 (Windows Vista , Windows XP SP 2, etc)

The following platforms are planned but have not yet been implemented / tested :

* .NET Compact Framework v3.5 (Windows Mobile 6, etc)
* Silverlight 2.0+

### Supported LINQ Syntax

The following is a list of the operators supported by CLINQ:

#### Supported operators
* Where
* Select
* SelectMany
* GroupBy
* OrderBy (Ascending/Descending)
* ThenBy (Ascending/Descending)
* GroupJoin
* Distinct
* Except
* Concat
#### Aggregation:
* ContinuousSum
* ContinuousContains
* ContinuousFirstOrDefault
* ContinuousMax
* ContinuousMin

CLINQ does **NOT** support:

* Join

# Smart Property Notification

Smart Property Notification was added to CLINQ in the [release:16757](release_16757) release.

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

# Sample Usage Scenarios

When should you use CLINQ? 
The short answer is : **_anytime you wish to declaratively define a result set that is dynamically and continuously fed from a source list._**

The following are a few situations that provide a more concrete example of where CLINQ truly adds value.

## Financial Order Book
In this usage scenario, your application is receiving a constant flood of market data ticks from some external source. 
Rather than writing code to listen for changes to market data in a background thread and then figure out how to 
pump all that data to the foreground thread, you can simply define a query against your singleton market data object
**tickerSource.AllTicks** and the ContinousCollection and CLINQ will take care of everything else. Changes that occur in the CLINQ
adapter chain pipeline are propagated on the Dispatcher thread, making them visible to the WPF data binder.

{{
    var ticks = from tick in tickerSource.AllTicks
                    where tick.Symbol == "AAPL" && 
                              tick.Price > 100 &&
                              tick.Price < 120
                    select tick;
    orderBook.DataContext = ticks; // WPF data binding
}}


## Network Message Monitor
In this scenario, an application is gathering events from multiple sources and placing them in an object called **AllEvents**. The sample
query below would enable an application to 'sit back' and listen, dynamically and continuously maintaining a result set that only
consists of network events that are considered critical.

{{
    var criticalAlerts = from msg in eventLog.AllEvents
        where msg.Priority == MessagePriority.Critical
        orderby msg.EventTimeStamp desc
        select msg;
}}

## Gaming (especially strategy / board games)
In this scenario, the player is in a 3D universe piloting their space ship. You might have Windows Workflow Foundation code that handles the
artificial intelligence of enemies. Wouldn't it be so much easier than writing background thread polling code to detect nearby enemies if you could
just define a collection called **enemiesNearby** and then just define an event handler that allows you to inject your AI logic when enemies come
in and out of radar range?

{{
    var enemiesNearby = 
      from gameObject in sharedState.AllGameObjects
      where gameObject.ObjectType == GameObjects.NPC &&
      gameObject.3DDistance(self) <= self.RadarRange // 3DDistance could be an extension method!
      select gameObject;
    
    enemiesNearby.CollectionChanged += 
      new NotifyCollectionChangedEventHandler(enemiesNearby_Changed); // respond to newly detected threats!
}}

## Administration / BI Console
In this sample scenario, you have an application that is monitoring KPIs (Key Performance Indicators) for a Business Intelligence workbench.
This application has a section of it's GUI dedicated to monitoring the failing KPIs throughout an organization. The following query shows how
you could define a single query to monitor all failing KPIs that can then be immediately bound to the WPF or WinForms GUI:

{{
   var needsAttention = from kpi in biSystem.KPIList
                                  where kpi.Status == KpiStatus.RedRange // KPI is failing, needs attention
                                  select kpi;
}}