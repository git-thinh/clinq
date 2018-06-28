# FAQ
## Cannot Change ObservableCollection During a CollectionChanged Event
"I am writing some code where, in response to an item being added to a collection in my adapter chain, I need to add an item to the source collection. 
I get the error message 'Cannot change ObservableCollection During a CollectionChanged Event'. Is there a way around this?"

Actually, yes, there is a way around it. If you are planning on inserting a row into the source collection which triggered the current event handler, you need to defer the work of adding the new item to a background thread, this will circumvent the re-entry barrier on ObservableCollection. Keep in mind, however, that putting it on the background thread won't save you if your code isn't designed to avoid an infinite loop of item additions - you will need to plan around that carefully. 

A detailed examination of this exact scenario, including the solution code, can be found here: 
[Adding to a Source Collection from a Collection Changed Event Handler](Adding-to-a-Source-Collection-from-a-Collection-Changed-Event-Handler)

## Is CLINQ Thread-Safe?
The short answer is, "no."  Any synchronization between threads must be done by you.  Using the ContinuousCollection class as your source collection will ensure that all updates happen on the dispatcher on which the collection was created (in a WPF scenario).  CLINQ will also guarantee that updates to the source collection or to properties are visible when the query is bound to a WPF control, as long as the source collection is created on the GUI dispatcher.  Other than that, no thread-safety guarantees are made.  That would make the code way too complex, and we seek to maintain only the core functionality necessary to make this all work.
