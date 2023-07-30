select * from airplane;

-- [1] add_airplane()
-- adds only two airplanes? 
call add_airplane('Delta', 'n281fc', 6, 500, 'plane_41', 'jet', null, null, 4);
call add_airplane('Delta', 'n506zp', 3, 300, 'plane_43', 'prop', true, 3, null);
call add_airplane('Lufthansa', 'n106js', 6, 500, 'plane_41', 'jet', null, null, 4);
call add_airplane('Delta', 'n506zp', 3, 300, 'plane_1', 'prop', true, 3, null);
call add_airplane('Delta', 'n506zp', 3, 300, 'plane_43', 'jet', true, 3, 4);

-- [2] add_airport()
call add_airport('JFK', 'John F_Kennedy International', 'New York', 'New York', 'USA', 'port_33');
-- Zap AIRPORT should NOT be added ? bc port_2 is not a valid location
call add_airport('ZAP', 'Area 51 Landing Zone', 'Roswell', 'New Mexico', 'USA', 'port_2');

select * from airport;
select * from airplane;
select * from person;
select * from location;
-- [3] add_person()
call add_person('p61', 'Sabrina', 'Duncan', 'port_1', '366-50-3732', 27, null, null);
-- line below should not modify database state bc 'p61' exists alr and 'port_2' does not exist
call add_person('p61', 'Kelly', 'Garrett', 'port_2', null, null, 451, 900);
-- line below should not modify database state bc 'port_100' does not exist
call add_person('p57', 'Jill', 'Munroe', 'port_100', '401-47-9115', 10, null, null);

-- [4] grant_or_revoke_pilot_license()
call grant_or_revoke_pilot_license('p1','jets');
call grant_or_revoke_pilot_license('p1','props');
call grant_or_revoke_pilot_license('p23','jets');
call grant_or_revoke_pilot_license('p100','props');

-- [5] offer_flight()
-- should add flight un_41
call offer_flight('un_41', 'americas_three', 'United', 'n330ss', 0, '11:30:00', 400);
-- should update cost to 900
call offer_flight('un_41', 'americas_three', 'United', 'n330ss', 0, '11:30:00', 900);
call offer_flight('lf_43', 'big_europe_loop', 'Lufthansa', 'n401fj', 2, '9:15:00', 100);
-- line below is giving me a foreign key error...
-- so there is no Pan Am airplane ...
call offer_flight('pa_19', 'big_europe_loop', 'Pan Am', 'n918my', 0, '10:00:00', 400);
-- no change to database state because 10 is too large of a progress
call offer_flight('un_41', 'americas_three', 'United', 'n330ss', 10, '11:30:00', 400);
-- add a flight without a airplane
call offer_flight('pa_19', 'big_europe_loop', null, null, 0, '10:00:00', 400);

select * from airplane;
select * from flight;
select * from route;
select * from leg;

select * from route_path;

-- [6] flight_landing()
call flight_landing('dl_10');
call flight_landing('un_38');
call flight_landing('km_16');
call flight_landing('ja_35');
call flight_landing('oh_99');
call flight_landing('ba_61');
call flight_landing('lf_20');

-- [7] flight_takeoff()
call flight_takeoff('am_96');
call flight_takeoff('lf_20');
call flight_takeoff('');
call flight_takeoff(null);
call flight_takeoff('oh_99');
call flight_takeoff('dl_10');
call flight_takeoff('ba_51');

-- [8] passengers_board()
call passengers_board('ba_61');
call passengers_board('lf_20');
call passengers_board('ry_34');
call passengers_board('ba_51');
call passengers_board('dl_10');

-- [9] passengers_disembark()
call passengers_disembark('ba_61');
call passengers_disembark('lf_20');
call passengers_disembark('ry_34');
call passengers_disembark('ba_51');
call passengers_disembark('dl_10');

-- [10] assign_pilot()
call assign_pilot('lf_20', 'p18');
call assign_pilot('ba_51', 'p20');
call assign_pilot('ry_34', 'p19');
call assign_pilot('ba_61', 'p17');

-- [11] recycle_crew()
select * from airplane;
select * from flight;
select locationID from airplane where tail_num = (select support_tail from flight where flightID = 'am_99'); 
call recycle_crew('am_99');
call recycle_crew('am_96');
call recycle_crew('lf_20');
call recycle_crew('am_86');

-- [12] retire_flight()
call retire_flight('am_86');
call retire_flight('km_16');
call retire_flight('am_99');

-- [13] simulation_cycle()
call simulation_cycle();

select * from flight;
select * from airplane;
select * from airline;
SELECT * FROM flights_in_the_air;

SELECT * FROM flights_on_the_ground;
SELECT * FROM people_on_the_ground;
select passenger.personID from passenger 
	inner join person on passenger.personID = person.personID
	where person.locationID = (select locationID from airplane where tail_num = 
	(select support_tail from flight where 'am_86' = flightID));
    
    
-- random testing for passengers board    
select
    airport.locationID as departing_from,
    airplane.seat_capacity as seat_capacity
from flight 
join route_path on flight.routeID = route_path.routeID and progress = sequence
join leg on route_path.legID = leg.legID
left join airplane on support_airline = airlineID and support_tail = tail_num
join airport on departure = airport.airportID
where flightID = 'am_86';    

select
    airport.airportID as next_destination,
    airplane.seat_capacity as seat_capacity
from flight 
join route_path on flight.routeID = route_path.routeID and (progress + 1) = sequence
join leg on route_path.legID = leg.legID
left join airplane on support_airline = airlineID and support_tail = tail_num
join airport on arrival = airport.airportID
where flightID = 'un_41';

select * from flights_on_the_ground;
select * from route_path where routeID = 'americas_three';
select * from leg where legID = 'leg_31' or legID = 'leg_14';
select * from flight;
SELECT * FROM people_in_the_air;

select * from person;
select * from passenger;
select * from passenger_vacations;
select locationID from person join passenger on person.personID = passenger.personID where passenger.funds > 100 and passenger.personID in (select personID from passenger_vacations where passenger_vacations.airportID = 'AMS' and sequence = 1);
select personID from passenger_vacations where passenger_vacations.airportID = 'AMS' and sequence = 1; 
select * from airport;
select * from pilot;
