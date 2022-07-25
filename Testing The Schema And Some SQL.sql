--------------------------------------------------------
--Mahmoud Basuony  -------------------------------------
---------------------------------------------------------
--1-What is the Num of the booked rooms in each hotels and the total Num of it!
--Created with a procedure
create proc NumOfRoomsInEachHotel
as
select  br.HotelCode , count(br.room_id_fk)
from booked_rooms br
group by rollup (br.HotelCode )

NumOfRoomsInEachHotel

/*2-How many times did the user use the system , and showing him ?*/

create proc UserRanking 
as 
select g.FirstNAme , g.FirstNAme , g.DOB , count(b.guestID) as"NumOfUseingSytstem" , ROW_NUMBER() over(order by count(b.guestID) desc) as "UserRanking"
from [dbo].[booking] b , [dbo].[Guest] g
where g.GuestID = b.GuestID
group by FirstNAme,FirstNAme,DOB

UserRanking


/*3-What is the income for each hotel in the system ? 	*/

create proc Revenue 
as
select h.HotelName , sum(bl.RoomCharge + bl.RoomService + bl.ResturantCharges) as 'TotalRevenue'  
from [dbo].[hotels] h , [dbo].[booking] b , [dbo].[booked_hotel] bh , [dbo].[bill] bl
where h.HotelCode = bh.Hotel_id_fk and b.BookingID = bh.Booking_id_fk and b.bookingID = bl.BookingID
group by h.HotelName

Revenue


/*4-what is the hotels located in a [city]*/

create proc HotelsDetails @city nvarchar(20)
as
 select * 
 from hotels
 where city = @city

 HotelsDetails 'giza'
 
/*5-From where every guest visite a city and booked at the city's hotels*/

create view cityHotels
as
select *from hotels h 

create proc guestVisitingCity @city nvarchar(20)
as
select g.FirstName+g.LastName as 'Full Name' , ch.HotelName , ch.City ,b.* 
from cityHotels ch , guest g , booking b , booked_hotel bh
where g.GuestID = b.GuestID and b.bookingID = bh.booking_id_fk and ch.HotelCode = bh.hotel_id_fk and ch.City = @city

guestVisitingCity 'giza'



/*6-Show the places that can the guest visit near of the bookend hotel*/

create trigger popup
on booked_hotel
after insert 
as
declare @city nvarchar(20)
select @city=City
from inserted i, hotels h
where  h.HotelCode = i.hotel_id_fk
select 'U can go to any whare u want in '+ @city
 

insert into booked_hotel values(31,5)

/*7-Like every one we wanna know some details about our guests */

create proc guestDetails @hotel nvarchar(30) , @name nvarchar(20) 
as
select g.GuestID , g.Gender , g.FirstName+g.LastName , gp.phone
from guest g , gustPhone gp , booking b , booked_hotel bh , hotels h
where g.GuestID = gp.GuestID and g.GuestID = b.GuestID and b.bookingID = bh.booking_id_fk 
and h.HotelCode = bh.Hotel_id_fk and h.HotelName = @hotel and g.FirstName = @name

guestDetails 'Gezira Sheraton' , 'Mahmoud'


/*8-How much money a hotel is earned in a specific mounth ? 	*/

alter proc HotelRevenueInMonth @hotelName nvarchar(30) , @m int
as
if(@hotelName != 'All')
begin
	select h.HotelName , sum(bl.RoomCharge) as revenue
	from [dbo].[hotels] h inner join  [dbo].[booked_hotel] bh
	on h.HotelCode = bh.Hotel_id_fk 
	inner join [dbo].[booking] b on  b.BookingID = bh.Booking_id_fk 
	inner join [dbo].[bill] bl on b.bookingID = bl.BookingID
	and month(b.ArrivalDate) = @m and h.HotelName = @hotelName
	group by h.HotelName
end
else
begin
	select * , DENSE_RANk() over(order by revenue desc) as ranking
	from(
		select h.HotelName , sum(bl.RoomCharge) as revenue
		from [dbo].[hotels] h inner join  [dbo].[booked_hotel] bh
		on h.HotelCode = bh.Hotel_id_fk 
		inner join [dbo].[booking] b on  b.BookingID = bh.Booking_id_fk 
		inner join [dbo].[bill] bl on b.bookingID = bl.BookingID
		and month(b.ArrivalDate) = @m 
		group by h.HotelName
		) as mm
end

HotelRevenueInMonth 'Gezira Sheraton' , 1
HotelRevenueInMonth 'All' , 1


/*9- Create a view that filter the room/hotel by the price ! */
create view FilterigWitheBudget
with encryption
as
select h.HotelName , r.roomType , r.price ,count(r.roomType) as NumOfRooms  
from hotels h inner join rooms r on h.HotelCode = r.Hotel_id_fk 
and r.price between 240 and 300
group by h.hotelName , r.roomType , r.price

select * from FilterigWitheBudget


/*10-Create a trigger that delete the room from bookedRooms table after making the Invoice in bill table*/

create trigger ReleaseTheRoom
on bill
after insert
as
declare @id int
select @id=i.BookingID
from inserted i

delete from booked_rooms 
where Booking_id_fk = @id

insert into bill(InvoiceNo,bookingID) values (31,31)

--select datename( month,(getdate()))



--11-list names hotels that have room or mor are not  booked
create proc listofroom 
as
select distinct h.*
from hotels h inner join rooms r on h.HotelCode = r.hotel_id_fk
inner join booked_rooms br on (r.roomID != br.room_id_fk and r.hotel_id_fk != br.HotelCode)



--call
listofroom




-----------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

----------------------------------Yasser Abdelgaber Mourtada-------------------------------

----------------------------------------------------------------------------------------------

--1)list all rooms that are booked at <date>

create proc allroom  @date date 
	as
	select br.HotelCode,br.room_id_fk,b.BookingTime
	from booking b inner join booked_rooms br on b.BookingID=br.booking_id_fk
	where b.BookingTime=@date

--call
declare @t table(hid int  , rid int,dat date)
insert into @t
execute allroom '2021-02-27 00:00:00'
select * from @t


----
----2- Write a query to rank the hotels according to The number of reservations they received during the period='      '
--without gapping in ranking

go
alter proc allhotels  @date1 datetime ,  @date2 datetime 
as	
 select * , ROW_NUMBER() over ( order by n_of_rev desc )  as r 
 from 
(select h.HotelName,h.City ,COUNT(bh.booking_id_fk) as n_of_rev
	 
    from booking b inner join booked_hotel bh on b.BookingID=bh.booking_id_fk
	inner join  hotels h on  h.HotelCode=bh.hotel_id_fk
	where b.BookingTime >= @date1  and b.BookingTime<@date2
	group by h.HotelName,h.City) newTable

	go

	--call

declare @d1 date='2020-01-05 00:00:00',@d2 date='2022-06-02 00:00:00'

execute	allhotels @d1,@d2
go

---
--3-rank the names of coustomer according to the values of bill
go
alter proc guestbill   
as
select g.FirstName,g.GuestID,b.BookingID,(b.ResturantCharges+b.RoomCharge+b.RoomService)as tatal,ROW_NUMBER()
over(order by (b.ResturantCharges+b.RoomCharge+b.RoomService) desc) as "order by bill"
from Guest g inner join bill b on  g.GuestID=b.GuestID  
--group by  g.FirstName,g.GuestID,b.BookingID
go

--call
guestbill


--4- function take the date and city return the room that not be booking in this date

go
alter proc notboocedroom @city varchar(1000),@date datetime
as
select  br.HotelCode,br.room_id_fk
from booked_rooms br join booking b on  br.booking_id_fk=b.BookingID join booked_hotel  bh on b.BookingID=bh.booking_id_fk
join hotels h on h.HotelCode=bh.hotel_id_fk join rooms r on r.hotel_id_fk=h.HotelCode
where h.City like @city  and @date not between b.ArrivalDate and b.DepartureDate 
 
go


--call

notboocedroom 'cairo','5-10-2021'


--
--5-function or proc take the city and the rate then return the names of hotels

go
create proc ratehotles @city varchar(100),@rate int
as
select h.HotelName,h.StarRating
from hotels h
where h.City like @city and h.StarRating=@rate
go

--call
ratehotles 'cairo',5


--
--6-function or proc take the hotel id and he date and return a restaurant charge for all customer in this hotel in this date

go
alter proc allresrant  @id int ,@date datetime,@num int output
as
select sum(bi.ResturantCharges) as re
from booked_hotel bh join booking b on bh.booking_id_fk=b.BookingID join bill bi on b.BookingID=bi.BookingID
where bh.hotel_id_fk=@id and bi.PaymentDate=@date
group by  bh.hotel_id_fk

go



---cal

declare @n int 
execute allresrant 1,'2020-01-15 00:00:00' , @n output


---
--7-proc that rank the customer according to number of times they use the system for booking
go
create proc rankallcustum   
	as
	select g.GuestID,count(b.BookingID)as numofbooking,ROW_NUMBER() OVER( ORDER BY count(b.BookingID) desc) AS rk
	from booking b  join Guest g on b.GuestID=g.GuestID
	group by  g.GuestID
	
	
	go

	--call
	rankallcustum
--------------
	--8-proc that rank the booking according to long time the customer the stay in hotel

	go
create proc howmanydays
as
SELECT b.GuestID,b.BookingID,b.ArrivalDate,b.DepartureDate,DATEDIFF(day , b.ArrivalDate,b.DepartureDate) AS date_difference,ROW_NUMBER()
OVER( ORDER BY DATEDIFF(day , b.ArrivalDate,b.DepartureDate) desc) AS rk
FROM booking b;


go


--call
howmanydays
--using user define function

--code in vs using c#:
 /*
 public static SqlString diffrentdate(SqlString d1, SqlString d2)
    {
        DateTime date1 = Convert.ToDateTime(d1.Value.ToString());
        DateTime date2 = Convert.ToDateTime(d2.Value.ToString());
        TimeSpan ts = date1 - date2;
        string s = Convert.ToString(ts);
        // Put your code here
        return new SqlString (s);
    }
	*/
go
declare @a datetime,@b datetime
select @a= [ArrivalDate] , @b=[DepartureDate]  from[dbo].[booking ] where [GuestID]=1

select  [booking].[dbo].[diffrentdate](@b,@a) as res
go


----
--9-proc or func that rank the room according to their price and groub it according their type
go
alter proc rankroomtype 
as
select r.roomType, r.price,r.hotel_id_fk,ROW_NUMBER() OVER(PARTITION BY r.roomType ORDER BY r.price desc) AS rk
from rooms r 

go

rankroomtype
go


----------
----10-proc and fun that take the date and hotel id then return the number of child in this hotel

go 
alter proc numchild @id int, @date datetime
as
select sum(b.NumChildren) as totalofchild
from booked_hotel bh join booking b on bh.booking_id_fk=b.BookingID
where bh.hotel_id_fk=@id and @date between b.ArrivalDate and b.DepartureDate



go
--call
numchild 2,'2021-03-06 00:00:00'



--11- func or proc that take the date and the hotel and return the number of people will arrive in this date at this hotels
go
alter proc numofpeople  @hid int ,@date datetime
as
select bh.hotel_id_fk ,sum(b.NumAdults+b.NumChildren)as numofpeople
from  booked_hotel bh  inner join booking b  on bh.booking_id_fk=b.BookingID 
where bh.hotel_id_fk=@hid and @date between b.ArrivalDate and b.DepartureDate
group by bh.hotel_id_fk
go

---call

numofpeople   2,'2021-03-06 00:00:00'





---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
----  -              3. Abdelrahman Abdelaal                   ----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

--Q1:Country which is the most in each hotel?
go
create view Nationality#1 as
SELECT   DENSE_RANK() OVER( ORDER BY count(g.Country) DESC) AS Country#1, g.Country
from booking b
join Guest g
ON b.GuestID = g.GuestID
GROUP BY g.Country
go
select * from Nationality#1



----2-Is this hotel suitable for honeymoon ?

create view HoneyMoonHotel as
SELECT distinct h.HotelName as HoneyMoonHotels
from booking b
join booked_hotel bh
on b.BookingID = bh.booking_id_fk
join hotels h
on h.HotelCode = bh.hotel_id_fk
where b.NumAdults=2 and b.NumChildren=0

select * from HoneyMoonHotel


--3-The most comfortable hotel?
go
alter view Hotel#1 as
select  DENSE_RANK() OVER( ORDER BY count(b.BookingID) DESC) AS Hotel#1, h.HotelName
from booking b
join booked_hotel bh
on b.BookingID = bh.booking_id_fk
join hotels h
on h.HotelCode = bh.hotel_id_fk
group by h.HotelName
go

select * from Hotel#1



---4-The best month for booking ?

create view BestTimeForBooking as
select MONTH(b.ArrivalDate)as "Month", count(MONTH(b.ArrivalDate)) as #Booking
from booking b
group by MONTH(b.ArrivalDate)
select * from BestTimeForBooking


--5-list  id customer  that booked more than one times
go
alter  proc allcustum      
	as
	select g.GuestID,count(b.BookingID)as numofbooking,ROW_NUMBER() OVER( ORDER BY count(b.BookingID) desc) AS rk
	from booking b  join Guest g on b.GuestID=g.GuestID join  booked_hotel bh on  bh.booking_id_fk=b.BookingID 
	group by  g.GuestID
	having count(b.BookingID)>=2
	
	
	go


	--call
allcustum
go
 execute allcustum
 go


 --6- rank the names of hotel according to the number of room
go
alter proc numofroom   
as
select h.HotelName , count(r.roomID)as numrom,ROW_NUMBER() over(order by count(r.roomID) desc) as "order by num of room"
from hotels h left outer join rooms r on h.HotelCode =h.HotelCode
group by  h.HotelName
go


--call
numofroom


---7-- proc that group all bill according the payment type
go
create proc typepay 
as
select b.InvoiceNo,pt.type 
from bill b join  pay_tybe pt on b.InvoiceNo=pt.billID
order by  pt.type


go
--call

typepay



---8-proc that  return all room and group it according the type of the room

go
create proc rooomtype 
as
select h.HotelCode,r.roomID,r.roomType ,ROW_NUMBER() OVER(PARTITION BY  r.roomType ORDER BY r.roomID desc) AS rk 
from hotels h join rooms r on r.hotel_id_fk=h.HotelCode


go
--call
rooomtype


---proc that take the hotel id and date of arrive and return their customer 
--with all information (email-phone- address-guest title)

go
alter function Gethotel( @hotel_ID int, @date_of_arrive varchar(50))
returns table
as 
return 
(
  select g.FirstName , gp.phone, g.Country , g.GuestTitle, g.Email
  from GustPhone gp inner join  guest g on gp.GuestID=g.GuestID inner join booking b on g.GuestID=b.GuestID inner join booked_hotel bh on bh.booking_id_fk=b.BookingID 
  where @hotel_ID = bh.hotel_id_fk and @date_of_arrive = b.ArrivalDate
)
go
select * from gethotel(1,'2020-01-07')


---10- func or proc that take the date and the hotel and return the number of people will leave hotels

go
alter proc numofpeopleleave  @hid int ,@date datetime
as
select bh.hotel_id_fk ,sum(b.NumAdults+b.NumChildren)as numofpeople
from  booked_hotel bh  inner join booking b  on bh.booking_id_fk=b.BookingID 
where bh.hotel_id_fk=@hid and @date = b.DepartureDate
group by bh.hotel_id_fk
go


---call

numofpeople   2,'2021-03-06 00:00:00'






------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
--------------------------Omar Mahmoud Abdelhafez------------------------------------------------
--------------------------------------------------------------------------------------------------



--1-view that displays the guests's data if the guest have a guest titel 

Create view VguestsALL 
as 

select * from Guest
where guesttitle is not null

select * from VguestsALL 



--2- view that displays Guests data for a guests who lives in Alex or Cairo.

Create view CairoAlex
with encryption
as 
Select * from VguestsALL
where City in ('Cairo' , 'Alex')
with check option


--3- view that will display the hotel name 
--and the number of booked guests for each one

Create view NumberOfBooking as

select h.HotelName ,  count(b.BookingID) as 'Number Of Bookings' 
from hotels h , booking b , Guest g , booked_hotel bh
where g.GuestID=b.GuestID and b.BookingID=bh.booking_id_fk and h.HotelCode=bh.hotel_id_fk

group by h.HotelName

select*
from NumberOfBooking

--3-Display Hotels and Address for hotels that are located in giza and have rate 5 .

go
with cte 
as 
(
 select HotelName ,h.Address , City
 from hotels h
 where StarRating=5 and City = 'Giza'
)
 select * from cte


--4-proc that take the hotel id and date of arrive and return their customer 
--with all information (email-phone- address-guest title)
go
alter function Gethotel( @hotel_ID int, @date_of_arrive varchar(50))
returns table
as 
return 
(
  select g.Email , gp.phone, g.Country , g.GuestTitle,g.FirstName
  from GustPhone gp inner join  guest g on gp.GuestID=g.GuestID inner join booking b on g.GuestID=b.GuestID inner join booked_hotel bh on bh.booking_id_fk=b.BookingID 
  where @hotel_ID = bh.hotel_id_fk and @date_of_arrive = b.ArrivalDate
)
go
select * from gethotel(1,'2020-01-07')


----5-rank the room according to the number of bed in the room
go
create proc numofbed   
as
select r.roomID,r.hotel_id_fk,r.numBed,ROW_NUMBER() over(PARTITION BY r.hotel_id_fk order by r.numBed desc) as "order by num of bed"
from rooms r

go
--call

numofbed



--6-function or proc take the city return the name of hotel in this city

go 
alter proc nameofhotels  @city varchar(100)
as

select  h.HotelName ,h.City,h.Country
from hotels h
where h.City like @city
go

---call
nameofhotels  'cairo'
go



--7-proc or func that take the date and return the special request in this date and group by according the hotel id

go
alter proc spreq @date datetime
as
select bh.hotel_id_fk,b.GuestID,b.SpecialReq,ROW_NUMBER() OVER(PARTITION BY b.SpecialReq ORDER BY bh.hotel_id_fk desc) AS rk
from booking b join booked_hotel bh on bh.booking_id_fk=b.BookingID
where b.BookingTime=@date
go

--call

declare @t datetime ='2021-02-27 00:00:00'
execute spreq @t



---8-proc that group all customer in the system according to their city

go
create proc allguest
as
select  g.GuestID,g.FirstName,g.City ,ROW_NUMBER() OVER(PARTITION BY g.City ORDER BY g.GuestID desc) AS rk
from  Guest g
go

--call
allguest



---9-proc or func that rank the room according to their price and groub it according the hotel
go
alter proc rankroomprice 
as
select h.HotelCode,h.HotelName, r.price,ROW_NUMBER() OVER(PARTITION BY h.HotelCode ORDER BY r.price desc) AS rk
from rooms r join hotels h on r.hotel_id_fk=h.HotelCode

go

rankroomprice
go


--10-proc that gruob the customer according to their gender
go
create proc  getcust
as
select  g.FirstName,g.Gender,ROW_NUMBER() over(PARTITION BY g.Gender order by  g.FirstName desc) as "order by name"
from  Guest g



go

---call
getcust


--11Proc or func that take date and return the all bill group according the hotel

go
alter function getbill(  @date date)
returns table
as 
return 
(
select   bh.hotel_id_fk , (bi.ResturantCharges+bi.RoomCharge+bi.RoomService)as tatal,ROW_NUMBER() over(PARTITION BY bh.hotel_id_fk order by (bi.ResturantCharges+bi.RoomCharge+bi.RoomService) desc) as "order by total"
from  booked_hotel bh  inner join booking b  on bh.booking_id_fk=b.BookingID  inner join bill bi  on bi.BookingID=b.BookingID
where bi.PaymentDate=@date
--group by bh.hotel_id_fk
)
go
select * from getbill('2021-03-06 00:00:00')





