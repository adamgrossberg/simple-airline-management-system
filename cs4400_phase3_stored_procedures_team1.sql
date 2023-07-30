-- CS4400: Introduction to Database Systems: Wednesday, July 12, 2023
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
##Checks requirement conditions before adding. 
##airlineID and locationID are foreign keys, so must be in airline and location tables respectively
##tail_number is a primary key attribute and cannot be null
##seat_capacity and speed must both be non-null and positive
if (ISNULL(ip_airlineID) = 0 and ip_airlineID in 
(select airlineID from airline) and ISNULL(ip_tail_num) = 0 and (ip_airlineID, ip_tail_num) not in 
(select airlineID, tail_num from airplane) 
and ISNULL(ip_locationID) = 0 and ip_locationID not in (select locationID from location)
and ISNULL(ip_seat_capacity) = 0 and ISNULL(ip_speed) = 0 and ip_seat_capacity > 0 and ip_speed > 0) THEN
insert into location values(ip_locationID);
insert into airplane values(ip_airlineID, ip_tail_num, ip_seat_capacity, 
ip_speed, ip_locationID, ip_plane_type, ip_skids,ip_propellers, ip_jet_engines);
END IF;
end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin
if (isnull(ip_airportID) = 0 and ip_airportID not in (select airportID from airport) 
and isnull(ip_city) = 0 and isnull(ip_state) = 0 and isnull(ip_country) = 0 
and isnull(ip_locationID) = 0 and ip_locationID not in (select locationID from location)) then
insert into location values(ip_locationID);
insert into airport values(ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);
end if;
end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin
if(isnull(ip_first_name) = 0 and isnull(ip_personID) = 0 and ip_personID not in (select personID from person) 
and ip_locationID in (select locationID from location)) then
insert into person values(ip_personID, ip_first_name, ip_last_name, ip_locationID);
if(isnull(ip_taxID) = 0) then #checks if the person is a pilot
insert into pilot values (ip_personID, ip_taxID, ip_experience, null);
else #if not a pilot, is a passenger
insert into passenger values (ip_personID, ip_miles, ip_funds);
end if;

end if;
end //
delimiter ;

-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it laready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
IF (isnull(ip_personID) = 0 and isnull(ip_license) = 0 and ip_personID in (select personID from pilot)) THEN
IF ((ip_personID, ip_license) in (select * from pilot_licenses))THEN
DELETE from pilot_licenses where (personID, license) = (ip_personID, ip_license);
ELSE
insert into pilot_licenses values(ip_personID, ip_license);
END IF;
END IF;
end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;

delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin

IF (ip_cost < 0 or ip_cost is null) then leave sp_main; end if;

IF (ip_routeID not in (select routeID from route)) 
	then leave sp_main; END if; -- Valid route checking
    
IF ((ip_support_airline, ip_support_tail) in (select support_airline, support_tail from flight)
or (ip_support_airline is not null and ip_support_tail is not null and 
(ip_support_airline, ip_support_tail) not in (select airlineID, tail_num from airplane)))
	then leave sp_main; END if; -- Airplane in use or is not null and doesn't exist
IF ip_progress >= (select max(sequence) from route_path where routeID = ip_routeID group by routeID) or ip_progress < 0
	then leave sp_main; END if; -- checking for a valid stop

# THis line ends the procedure if the flight already exists. 
IF (ip_flightID in (select flightID from flight)) then leave sp_main; end if; 
-- This block of code would update flight information for a currently existing flight. 
-- if (ip_flightID in (select flightID from flight)) then
-- 	update flight
--     set routeID = ip_routeID,
-- 		support_airline = ip_support_airline,
--         support_tail = ip_support_tail,
--         progress = ip_progess,
--         airplane_status = 'on_ground',
--         next_time = ip_next_time,
--         cost = ip_cost
--     where flightID = ip_flightID; leave sp_main; END if;
    
insert into flight values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 
	 'on_ground', MOD(ip_next_time, 240000), ip_cost);


end //
delimiter ;


-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin

DECLARE dist integer DEFAULT 0; # The distance of the leg just travelled. Used to reward FFM to passengers. 
DECLARE pos integer DEFAULT 0; #The leg sequence # most recently travelled

if(isnull(ip_flightID) = 0 and ip_flightID in (select flightID from flight) and
(select airplane_status from flight where flightID = ip_flightID) = 'in_flight') 
then #makes sure flight exists and is in the air
update flight #updates the attributes about the flight that need to be updated
set next_time = MOD(next_time + 10000, 240000), airplane_status = 'on_ground'
where flightID = ip_flightID;

update pilot
set experience = experience + 1
where commanding_flight = ip_flightID;

set pos = (select progress from flight where flightID = ip_flightID);
set dist = (select distance from leg where leg.legID in (select legID from route_path
where routeID in (select routeID from flight where flightID = ip_flightID) and sequence = pos));

update passenger
set miles = miles + dist
where personID in (select personID from person where locationID in 
(select locationID from airplane where (airlineID, tail_num) in 
(select support_airline, support_tail from flight where flightID = ip_flightID)));
end if;
end //
delimiter ;


-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin

declare legTime time default '00:00:00';
declare numpilots integer default 0;
declare planeType varchar(100);

IF ((select progress from flight where flightID = ip_flightID) >= (select max(sequence) from route_path 
where routeID = (select routeID from flight where flightID = ip_flightID)))
Then leave sp_main; end if;

set planeType = (Select plane_type from airplane where (airlineID, tail_num) in  
	(select support_airline, support_tail from flight where flightID = 'lf_20'));
IF (planeType = 'prop') then set numpilots = 1;
		ELSE set numpilots = 2; END if;
IF ((Select count(*) from pilot where commanding_flight = ip_flightID) < numpilots) then
	update flight
    set next_time = MOD(next_time + 3000, 240000)
    where flightID = ip_flightID;
    leave sp_main; END if;
    
    set legTime = leg_time((select distance from leg where legID in
		(select legID from route_path where (routeID, sequence - 1) in
        (select routeID, progress from flight where flightID = ip_flightID))),
        (select speed from airplane where (airlineID, tail_num) in
        (select support_airline, support_tail from flight where flightID = ip_flightID)));
        
	update flight 
    set airplane_status = 'in_flight',
    progress = progress + 1,
    next_time = MOD(next_time + legTime, 240000)
    where flightID = ip_flightID;

end //
delimiter ;



-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
DECLARE cap integer DEFAULT 0; #Total number of eligible passengers to board
DECLARE onboard integer DEFAULT 0; #The number of passengers currently on the plane
DECLARE ploc varchar(50); #the locationID of the airplane
DECLARE port varchar(50); #locationID of the airport where the airplane is currently located
DECLARE prog int default 0; #progress int value of the flight
DECLARE route varchar(50); #routeID of the flight
## Will only run if the airplane is currently on the ground
if((select airplane_status from flight where flightID = ip_flightID) = 'on_ground') then #OUTER LOOP 1

set prog = (select progress from flight where flightID = ip_flightID); #Gets progress value
set route = (select routeID from flight where flightID = ip_flightID); #Gets the routeID
set ploc = (select locationID from airplane where (airlineID, tail_num) in 
(select support_airline, support_tail from flight where flightID = ip_flightID));

# Makes sure the plane has a future destination
IF (prog < (select max(sequence) from route_path where routeID = route)) THEN
# Gets the airport the airplane currently is
IF (prog = 0) THEN 
set port = (select locationID from airport where airportID in (select departure from leg where legID in (
select legID from route_path where routeID = route and 1 = sequence)));
ELSE 
set port = (select locationID from airport where airportID in (select arrival from leg where legID in (
select legID from route_path where routeID = route and prog = sequence)));
END IF; 
set onboard = (select count(*) from person where personID in #Computes the number of people currently on the plane
(select personID from passenger) and locationID = ploc);


# Counts the number of potential passengers. 
set cap = (select count(*) from passenger_vacations where personID in 
(select personID from person where locationID = port) #finds all the people currently at the right airport
#checks if their preferred destination is one of the stops
and airportID in (select airportID from airport where airportID in( 
select arrival from leg where legID in 
(select legID from route_path where routeID = route and sequence > prog))) and sequence = 1 
and personID in (select personID from passenger where funds >= (select cost from flight where flightID = ip_flightID)));
# Makes sure that people can actually board the plane
IF (cap + onboard <= (select seat_capacity from airplane where locationID = ploc) and cap > 0) THEN #OUTER LOOP 3


update person
set locationID = ploc
where personID in (select personID from passenger_vacations where (airportID in (
select airportID from airport where airportID in(select arrival from leg where legID in 
(select legID from route_path where routeID = route and sequence > prog))) and sequence = 1)) and locationID = port
and personID in (select personID from passenger where funds >= (select cost from flight where flightID = ip_flightID));

END IF; ##OUTER LOOP 3
END IF; ##OUTER LOOP 2
END IF; ##OUTER LOOP 1
end //
delimiter ;


-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
declare airportName varchar(50);
declare airportLocation varchar(50);
declare airplaneLocation varchar(50);
IF ip_flightID is null or 
	(select airplane_status from flight where ip_flightID = flightID) = 'in_flight' then 
		leave sp_main; END if; -- Checking flight status
        
select l.departure into airportName from flight f join route_path on f.routeID = route_path.routeID
	join leg l on route_path.legID = l.legID where flightID = ip_flightID and progress = sequence; -- Checking airport name
    
select locationID into airportLocation from flight f join route_path on f.routeID = route_path.routeID 
    join leg l on route_path.legID = l.legID join airport on departure = airportID
		where flightID = ip_flightID and progress = sequence; -- Checking location

select airplane.locationID into airplaneLocation from flight left join airplane on support_airline = airlineID 
	and support_tail = tail_num where flightID = ip_flightID;
    
update passenger join passenger_vacations on passenger.personID = passenger_vacations.personID
    join person on person.personID = passenger.personID set person.locationID = airportLocation
		where person.locationID = airplaneLocation and passenger.personID in 
			(select personID from passenger_vacations where passenger_vacations.airportID = airportName and sequence = 1);

    delete from passenger_vacations 
    where airportID = airportName and sequence = 1 and personID in (select personID from person where locationID = airportLocation);

    DROP TEMPORARY TABLE IF EXISTS temp_sequence_update;


    CREATE TEMPORARY table temp_sequence_update
    
    SELECT personID, 
        ROW_NUMBER() OVER (PARTITION BY personID ORDER BY sequence) as new_sequence
    FROM passenger_vacations;

    UPDATE passenger_vacations 
    JOIN temp_sequence_update ON passenger_vacations.personID = temp_sequence_update.personID AND passenger_vacations.sequence = temp_sequence_update.new_sequence
    SET passenger_vacations.sequence = temp_sequence_update.new_sequence;

    -- Drop temporary table
    DROP TEMPORARY TABLE temp_sequence_update;
end //
delimiter ;

-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin
DECLARE ploc varchar(50); # the locationID of the plane operating the flight
DECLARE ptype varchar(100); #propeller or jet
DECLARE port varchar(50);
DECLARE route varchar(50);


set ploc = (select locationID from airplane where (airlineID, tail_num) in 
(select support_airline, support_tail from flight where flightID = ip_flightID));
set ptype = (select plane_type from airplane where locationID = ploc);
set route = (select routeID from flight where flightID = ip_flightID);

if (ip_personID in (select personID from pilot) and (ip_personID, concat(ptype, 's')) in (select * from pilot_licenses)
and (select airplane_status from flight where flightID = ip_flightID) = 'on_ground') then

#Gets the current airport the plane is at
IF ((select progress from flight where flightID = ip_flightID) = 0) THEN 
set port = (select locationID from airport where airportID in (select departure from leg where legID in (
select legID from route_path where routeID = route and 1 = sequence)));
ELSE 
set port = (select locationID from airport where airportID in (select arrival from leg where legID in (
select legID from route_path where routeID = route and 
(select progress from flight where flightID = ip_flightID) = sequence)));
END IF; 


if ((select locationID from person where personID = ip_personID) = port) then
update person 
set locationID = ploc
where personID = ip_personID;
end if;
end if;
end //
delimiter ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin
declare onboard int default 0;
if ip_flightID is null then leave sp_main; end if;
#Check that the plane is empty
set onboard = (select count(*) from person where personID in #Computes the number of people currently on the plane
(select personID from passenger) and locationID = ploc);
if onboard = 0 and ((select airportID from airport where locationID = ploc) in (end)) then
#Remove Pilots
update pilot
set commanding_flight = null
where commanding_flight = ip_flightID;
end if;
end //

delimiter ;


-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin
DECLARE start varchar(50); #The airportID of the start airport
DECLARE end varchar(50); #The airportID of the end airport
DECLARE ploc varchar(50); #The locationID of the airplane
DECLARE port varchar(50); #the locationID of the airport currently at
DECLARE route varchar(50); #The routeID of the flight
DECLARE numLegs int default 0;

## MAKES SURE FLIGHT IS GROUNDED BEFORE RUNNING ANYTHING
if((select airplane_status from flight where flightID = ip_flightID) = 'on_ground') THEN #OUTER LOOP 1
#Gets the plane and plane location values stored
set ploc = (select locationID from airplane where (airlineID, tail_num) in 
(select support_airline, support_tail from flight where flightID = ip_flightID));


##MAKES SURE AIRPLANE IS EMPTY BEFORE RUNNING ANYTHING
IF ((select count(*) from person where locationID = ploc) = 0)
THEN   #OUTER LOOP 2
set route = (select routeID from flight where flightID = ip_flightID);
set numLegs = (select count(*) from route_path where routeID = route);
set start = (select airportID from airport where airportID in (
select departure from leg where legID in(
select legID from route_path where routeID = route and sequence = 1 #Gets the first leg of the sequence
)));

set end = (select airportID from airport where airportID in (
select arrival from leg where legID in(
select legID from route_path where routeID = route and sequence = numLegs #Gets the last leg of the sequence
)));

#Gets the locationID for the current airport
IF ((select progress from flight where flightID = ip_flightID) = 0) THEN 
set port = (select locationID from airport where airportID in (select departure from leg where legID in (
select legID from route_path where routeID = route and 1 = sequence)));
ELSE 
set port = (select locationID from airport where airportID in (select arrival from leg where legID in (
select legID from route_path where routeID = route and 
(select progress from flight where flightID = ip_flightID) = sequence)));
END IF; 


# Makes sure the airport is at either the start or the end of the route
IF ((select airportID from airport where locationID = port) in (start, end)) THEN #OUTER LOOP 3
delete from flight where flightID = ip_flightID; #Deletes the flight
END IF; ##OUTER LOOP 3
END IF; ##OUTER LOOP 2
END IF; ##OUTER LOOP 1
end //
delimiter ;

-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

  DECLARE currentFlightID VARCHAR(50);
  DECLARE currentProgress INT;
  DECLARE nextTime TIME;
  DECLARE isLandingFlight BOOLEAN;
  
  -- Find the next flight to simulate (the one with the smallest next_time)
  SELECT flightID, progress, next_time, 
         IF(airplane_status = 'in_flight', 1, 0) AS is_landing_flight
  INTO currentFlightID, currentProgress, nextTime, isLandingFlight
  FROM flight
  ORDER BY nextTime, isLandingFlight DESC, flightID
  LIMIT 1;
  
	if(isnull(currentFlightID) = 0) then
    -- If an airplane is in_flight and waiting to land
	if(is_landing_flight) then
    call flight_landing(currentFlightID);
    call passengers_disembark(currentFlightID);
    -- If an airplane is on_ground and waiting to takeoff
    else if(is_landing_flight and currentProgress < 
    (select count(sequence) from route_path where routeID = 
    (select routeID from flight where flightID = currentFlightID))) then
    call passengers_board(currentFlightID);
    call flight_takeoff(currentFlightID);
    -- If a flight is at the end of its route
    else
    call recycle_crew(currentFlightID);
    call retire_flight(currentFlightID);
    end if;
    end if;
    end if;
end //
delimiter ;

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select l.departure as departing_from, l.arrival as arriving_at, count(distinct f.flightID) as num_flights, 
group_concat(distinct concat(f.flightID) order by f.flightID asc separator ',') flight_list, 
min(f.next_time) as earliest_arrival, max(f.next_time) as latest_arrival, 
group_concat(a.locationID order by f.flightID asc separator ',') airplane_list
from flight as f join route_path rp on f.routeID = rp.routeID and f.progress = rp.sequence join leg l 
on rp.legID = l.legID left join airplane a on f.support_airline = a.airlineID and f.support_tail = a.tail_num
where airplane_status = 'in_flight'
group by l.departure, l.arrival; 

-- [15] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
	
select l.departure as departing_from,
	count(f.flightID) as num_flights,
    group_concat(f.flightID order by f.flightID asc separator ',') flight_list,
    min(f.next_time) as earlies_arrival,
    max(f.next_time) as latest_arrival,
    group_concat(distinct concat(a.locationID) order by f.flightID asc separator ',') as airplane_list
    from flight f join route_path rp on f.routeID = rp.routeID and f.progress = rp.sequence
    join leg l on rp.legID = l.legID left join airplane a on f.support_airline = a.airlineID and f.support_tail = a.tail_num
    where f.airplane_status = 'on_ground'
    group by l.departure, l.arrival;

-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
select l.departure as departing_from, l.arrival as arriving_at, count(distinct f.flightID) as num_airplanes, 
group_concat(distinct concat(a.locationID) order by f.flightID asc separator ',') airplane_list, 
group_concat(distinct concat(f.flightID) order by f.flightID asc separator ',') flight_list,
min(f.next_time) as earliest_arrival, max(f.next_time) as latest_arrival, count(pil.personID) as num_pilots, count(pa.personID) as 
num_passengers, count(p.personID) as joint_pilots_passengers, group_concat(p.personID order by p.personID asc separator ',')
person_list
from flight as f join route_path as rp on rp.routeID = f.routeID and rp.sequence = f.progress join leg l on rp.legID = l.legID
left join airplane a on a.airlineID = f.support_airline and a.tail_num = f.support_tail left join person as p 
on p.locationID = a.locationID left join pilot pil on p.personID = pil.personID left join passenger pa on p.personID = pa.personID
where airplane_status = 'in_flight'
group by l.departure, l.arrival;

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select 
a.airportID as departing_from,
a.locationID as airport,
a.airport_name,
a.city,
a.state,
a.country,
(select COUNT(*) from person p1 where p1.locationID = a.locationID and p1.personID in
	(select personID from pilot)) as num_pilots,
(select COUNT(*) from person p2 where p2.locationID = a.locationID and p2.personID in
	(select personID from passenger)) as num_passengers,
COUNT(*) as joint_pilots_passengers, 
group_concat(p.personID) as person_list 
from person p join airport a on p.locationID = a.locationID group by a.airportID;


-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select rp.routeID, count(distinct l.legID), group_concat(distinct concat(l.legID) order by rp.sequence asc separator ',') 
leg_sequence, sum(l.distance), count(distinct f.flightID), 
group_concat(distinct concat(f.flightID) order by f.flightID asc separator ',') flight_list, 
group_concat(distinct concat(l.departure, '->', l.arrival) order by rp.sequence asc separator ',') airport_sequence
from route_path rp join leg l on rp.legID = l.legID left join flight f on rp.routeID = f.routeID group by rp.routeID;
   


-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
select city, state, country, count(distinct aiportID) as "num_airports",
group_concat(distinct concat(airportID) order by airportID asc separator ',') as "airport_code_list", 
group_concat(distinct concat(airport_name) order by airport_name asc separator ',') as "airport_name_list"
from airport
group by city, state, country;
