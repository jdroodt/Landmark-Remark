# Landmark-Remark
Coding test for Concentrix



Jan-Dawid (JD) Roodt - Landmark Remark


I unfortunately ran out of time as I struggled quite a bit to get the Firebase cocoapods working on my M1 (arm) chip MacMini. I knew about some issues Google has been having but I thought I might be able to fix it using the beta releases of Firebase/Firestore. Unfortunately I couldn't fix it in a reasonable timeframe and decided to move on using Rosetta. 


Installation instructions:
1. Install Cocoapods
2. If you're using a M1 mac please quit XCode and run under Rosetta from Applications, right-click, "get info", and check "Open using Rosetta"
3. Open the .xcworkspace file and compile.


Thought Process:

- I decided to use Firebase's no-SQL database Firestore as my database. I have experience with their realtime database but I wanted to give this new structure a go because it's more suitable for data that needs to be queried by lots of fields.
- I decided to stick to MapKit for the actual map but I did consider using GoogleMaps but I tried to stay away from too many 3rd party libraries to show a native experience
- UI/UX - I split the search functionality and the map as it seemed slightly easier to read and mark the code that way.


Known bugs and future improvements:

- ListViewController - cellForRow delegate uses a callback to set up a cell. Obviously you should never rely on a completion handler to set things on a cell as it can't guarantee you're updating the correct cell. ie If you scroll really fast cells will have wrong data. The fix is really easy but time consuming. I would have wanted to create a custom cell that stores it's indexPath.row value and the completion handler would compare the local row value to the cell's delegate row value and only update UI if they match. I'd even go further and keep a reference to the process getting the "place" and cancel it next time the delegate tries to assign a value.

- I wanted to create a fancy profile page when a user signs in using username and password but I thought I should focus on a MVP so it's just a username input.

- I wanted to do custom marker clustering for performance and then show a list of annotations in a cluster but ended up never refining the default clustering behaviour

- I originally planned to create a protocol that would send you to the specific annotation when you clicked on one of the list items but prioritised smooth search functionality instead and just showed a dialog of the data.

- The main bug with all of this is that I download all Notes to the device and sort them locally. That works for a couple of thousand notes but won't work at scale. I did howeve, design my database to cover that situation using FirebaseFirestoreSwift's GeoLocation. It has the ability to query for Notes based on a location and a distance around it. That would improve quality significantly and you can also query using other fields like username. I wouldn't have been able to do a "contains" search but I would have been able to do a search from the front of the string. Unfortunately that's not really ideal and would require another service like Firestore Cloud functions. 





