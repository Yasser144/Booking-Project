# Documentation:
## The Idea:
The idea of the project is that we create a hotel reservation system at the global level so that people who want to travel to another place that they do not know much about can have an overview of the places they are hope to enjoy according to the way they search/filter and what they are looking for.
## Discussion:
There are two types of users on the system: 
•	The user side, which is that the user can sign in on the system without making a reservation in any hotel.
He can also, of course, make a reservation on any of the hotels that are on the system at anytime and anywhere around the world.
There are some advantages that the user can enjoy, such as what hotels are available in the specified country or in the specified city.
He can also see the rating for each hotel and the prices according to what he is looking for
•	The side of the hotel, which has the ability to register on the site all the data that helps the user to choose the best for him.
         Where he enters data from the name, location, evaluation, number of                               
          rooms, types of rooms and some information about them...etc.

## What the system Consists of: 
- Guest Table: Here is all about the user, including complete data about him, and so on.
Also has a child table for the phones he/she has (GuestPhone)
- Bill Table: What is related to financial payments from bills and the payment method that belongs to the user/guest. 
Also has a child table for the type of payment (pay _ type)
- Booking Table: I call it “The Master table” ^~^
Because it contains information about the user, what he did, in what period the reservation was made, the number of rooms that were booked, and the number of individuals whether adults or children
- Hotels Table: The hotel table and any information characteristics related to the hotel.
- Rooms Table: It has all the rooms of all hotels linked to a specific hotel and also has all the information about the rooms from prices and so on.
- booked_rooms: The result of the relationship between booking table and rooms table.
- booked_hotel: The result of the relationship between booking table and hotels table.

## System Diagram:
![6](https://user-images.githubusercontent.com/37305730/175664236-13ff9be0-41c2-4c5f-bbda-b70b6ce3c92c.PNG)

## Loading the data (Ex: Fact Table)
![بطلللللل](https://user-images.githubusercontent.com/37305730/179095783-ead438ba-5fe5-45fb-b276-bec08567e3ae.PNG)


