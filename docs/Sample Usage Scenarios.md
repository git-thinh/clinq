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