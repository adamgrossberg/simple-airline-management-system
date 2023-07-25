-- CS4400: Introduction to Database Systems: Friday, May 26, 2023
-- Simple Airline Management System Course Project Database (v0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
drop database if exists flight_tracking;
create database if not exists flight_tracking;
use flight_tracking;

-- Define the database structures
create table airline (
	airlineID varchar(50),
    revenue integer default null,
    primary key (airlineID)
) engine = innodb;

insert into airline values ('Delta', 53000);
insert into airline values ('United', 48000);
insert into airline values ('British Airways', 24000);
insert into airline values ('Lufthansa', 35000);
insert into airline values ('Air France', 29000);
insert into airline values ('Ryanair', 10000);
insert into airline values ('Japan Airlines', 9000);
insert into airline values ('China Southern Airlines', 14000);
insert into airline values ('KLM', 29000);
insert into airline values ('Korean Air Lines', 10000);
insert into airline values ('American', 52000);

create table location (
	locationID varchar(50),
    primary key (locationID)
) engine = innodb;

insert into location values ('port_1');
insert into location values ('port_2');
insert into location values ('port_3');
insert into location values ('port_10');
insert into location values ('port_17');
insert into location values ('plane_1');
insert into location values ('plane_5');
insert into location values ('plane_8');
insert into location values ('plane_13');
insert into location values ('plane_20');
insert into location values ('port_12');
insert into location values ('port_14');
insert into location values ('port_15');
insert into location values ('port_20');
insert into location values ('port_4');
insert into location values ('port_16');
insert into location values ('port_11');
insert into location values ('port_23');
insert into location values ('port_7');
insert into location values ('port_6');
insert into location values ('port_13');
insert into location values ('port_21');
insert into location values ('port_18');
insert into location values ('port_22');
insert into location values ('plane_6');
insert into location values ('plane_18');
insert into location values ('plane_7');
insert into location values ('plane_4');
insert into location values ('plane_11');
insert into location values ('plane_26');
insert into location values ('plane_27');
insert into location values ('plane_16');
insert into location values ('plane_9');

create table airplane (
	airlineID varchar(50),
    tail_num varchar(50),
    seat_capacity integer not null check (seat_capacity > 0),
    speed integer not null check (speed > 0),
    locationID varchar(50) default null,
    plane_type varchar(100) default null,
    skids boolean default null,
    propellers integer default null,
    jet_engines integer default null,
    primary key (airlineID, tail_num),
    constraint fk1 foreign key (airlineID) references airline (airlineID),
    constraint fk3 foreign key (locationID) references location (locationID)
) engine = innodb;

insert into airplane values ('Delta', 'n106js', 4, 800, 'plane_1', 'jet', null, null, 2);
insert into airplane values ('Delta', 'n110jn', 5, 800, null, 'jet', null, null, 2);
insert into airplane values ('Delta', 'n127js', 4, 600, null, 'jet', null, null, 4);
insert into airplane values ('United', 'n330ss', 4, 800, 'plane_4', 'jet', null, null, 2);
insert into airplane values ('United', 'n380sd', 5, 400, 'plane_5', 'jet', null, null, 2);
insert into airplane values ('British Airways', 'n616lt', 7, 600, 'plane_6', 'jet', null, null, 2);
insert into airplane values ('British Airways', 'n517ly', 4, 600, 'plane_7', 'jet', null, null, 2);
insert into airplane values ('Lufthansa', 'n620la', 4, 800, 'plane_8', 'jet', null, null, 4);
insert into airplane values ('Lufthansa', 'n401fj', 4, 300, 'plane_9', null, null, null, null);
insert into airplane values ('Lufthansa', 'n653fk', 6, 600, null, 'jet', null, null, 2);
insert into airplane values ('Air France', 'n118fm', 4, 400, 'plane_11', 'prop', FALSE, 2, null);
insert into airplane values ('Air France', 'n815pw', 3, 400, null, 'jet', null, null, 2);
insert into airplane values ('KLM', 'n161fk', 4, 600, 'plane_13', 'jet', null, null, 4);
insert into airplane values ('KLM', 'n337as', 5, 400, null, 'jet', null, null, 2);
insert into airplane values ('KLM', 'n256ap', 4, 300, null, 'prop', FALSE, 2, null);
insert into airplane values ('Ryanair', 'n156sq', 8, 600, 'plane_16', 'jet', null, null, 2);
insert into airplane values ('Ryanair', 'n451fi', 5, 600, null, 'jet', null, null, 4);
insert into airplane values ('Ryanair', 'n341eb', 4, 400, 'plane_18', 'prop', TRUE, 2, null);
insert into airplane values ('Ryanair', 'n353kz', 4, 400, null, 'prop', TRUE, 2, null);
insert into airplane values ('Japan Airlines', 'n305fv', 6, 400, 'plane_20', 'jet', null, null, 2);
insert into airplane values ('Japan Airlines', 'n443wu', 4, 800, null, 'jet', null, null, 4);
insert into airplane values ('China Southern Airlines', 'n454gq', 3, 400, null, null, null, null, null);
insert into airplane values ('China Southern Airlines', 'n249yk', 4, 400, null, 'prop', FALSE, 2, null);
insert into airplane values ('Korean Air Lines', 'n180co', 5, 600, null, 'jet', null, null, 2);
insert into airplane values ('American', 'n448cs', 4, 400, null, 'prop', TRUE, 2, null);
insert into airplane values ('American', 'n225sb', 8, 800, 'plane_26', 'jet', null, null, 2);
insert into airplane values ('American', 'n553qn', 5, 800, 'plane_27', 'jet', null, null, 2);

create table airport (
	airportID char(3),
    airport_name varchar(200),
    city varchar(100) not null,
    state varchar(100) not null,
    country char(3) not null,
    locationID varchar(50) default null,
    primary key (airportID),
    constraint fk2 foreign key (locationID) references location (locationID)
) engine = innodb;

insert into airport values ('ATL', 'Atlanta Hartsfield_Jackson International', 'Atlanta', 'Georgia', 'USA', 'port_1');
insert into airport values ('DXB', 'Dubai International', 'Dubai', 'Al Garhoud', 'UAE', 'port_2');
insert into airport values ('HND', 'Tokyo International Haneda', 'Ota City', 'Tokyo', 'JPN', 'port_3');
insert into airport values ('LHR', 'London Heathrow', 'London', 'England', 'GBR', 'port_4');
insert into airport values ('IST', 'Istanbul International', 'Arnavutkoy', 'Istanbul ', 'TUR', null);
insert into airport values ('DFW', 'Dallas_Fort Worth International', 'Dallas', 'Texas', 'USA', 'port_6');
insert into airport values ('CAN', 'Guangzhou International', 'Guangzhou', 'Guangdong', 'CHN', 'port_7');
insert into airport values ('DEN', 'Denver International', 'Denver', 'Colorado', 'USA', null);
insert into airport values ('LAX', 'Los Angeles International', 'Los Angeles', 'California', 'USA', null);
insert into airport values ('ORD', 'O_Hare International', 'Chicago', 'Illinois', 'USA', 'port_10');
insert into airport values ('AMS', 'Amsterdam Schipol International', 'Amsterdam', 'Haarlemmermeer', 'NLD', 'port_11');
insert into airport values ('CDG', 'Paris Charles de Gaulle', 'Roissy_en_France', 'Paris', 'FRA', 'port_12');
insert into airport values ('FRA', 'Frankfurt International', 'Frankfurt', 'Frankfurt_Rhine_Main', 'DEU', 'port_13');
insert into airport values ('MAD', 'Madrid Adolfo Suarez_Barajas', 'Madrid', 'Barajas', 'ESP', 'port_14');
insert into airport values ('BCN', 'Barcelona International', 'Barcelona', 'Catalonia', 'ESP', 'port_15');
insert into airport values ('FCO', 'Rome Fiumicino', 'Fiumicino', 'Lazio', 'ITA', 'port_16');
insert into airport values ('LGW', 'London Gatwick', 'London', 'England', 'GBR', 'port_17');
insert into airport values ('MUC', 'Munich International', 'Munich', 'Bavaria', 'DEU', 'port_18');
insert into airport values ('MDW', 'Chicago Midway International', 'Chicago', 'Illinois', 'USA', null);
insert into airport values ('IAH', 'George Bush Intercontinental', 'Houston', 'Texas', 'USA', 'port_20');
insert into airport values ('HOU', 'William P_Hobby International', 'Houston', 'Texas', 'USA', 'port_21');
insert into airport values ('NRT', 'Narita International', 'Narita', 'Chiba', 'JPN', 'port_22');
insert into airport values ('BER', 'Berlin Brandenburg Willy Brandt International', 'Berlin', 'Schonefeld', 'DEU', 'port_23');

create table person (
	personID varchar(50),
    first_name varchar(100) not null,
    last_name varchar(100) default null,
    locationID varchar(50) not null,
    primary key (personID),
    constraint fk8 foreign key (locationID) references location (locationID)
) engine = innodb;

insert into person values ('p1', 'Jeanne', 'Nelson', 'plane_1');
insert into person values ('p2', 'Roxanne', 'Byrd', 'plane_1');
insert into person values ('p3', 'Tanya', 'Nguyen', 'plane_5');
insert into person values ('p4', 'Kendra', 'Jacobs', 'plane_5');
insert into person values ('p5', 'Jeff', 'Burton', 'plane_6');
insert into person values ('p6', 'Randal', 'Parks', 'plane_6');
insert into person values ('p7', 'Sonya', 'Owens', 'plane_8');
insert into person values ('p8', 'Bennie', 'Palmer', 'plane_18');
insert into person values ('p9', 'Marlene', 'Warner', 'plane_8');
insert into person values ('p10', 'Lawrence', 'Morgan', 'plane_8');
insert into person values ('p11', 'Sandra', 'Cruz', 'plane_13');
insert into person values ('p12', 'Dan', 'Ball', 'plane_18');
insert into person values ('p13', 'Bryant', 'Figueroa', 'plane_13');
insert into person values ('p14', 'Dana', 'Perry', 'plane_13');
insert into person values ('p15', 'Matt', 'Hunt', 'plane_20');
insert into person values ('p16', 'Edna', 'Brown', 'plane_20');
insert into person values ('p17', 'Ruby', 'Burgess', 'port_10');
insert into person values ('p18', 'Esther', 'Pittman', 'port_12');
insert into person values ('p19', 'Doug', 'Fowler', 'port_23');
insert into person values ('p20', 'Thomas', 'Olson', 'port_4');
insert into person values ('p21', 'Mona', 'Harrison', 'plane_1');
insert into person values ('p22', 'Arlene', 'Massey', 'plane_1');
insert into person values ('p23', 'Judith', 'Patrick', 'plane_1');
insert into person values ('p24', 'Reginald', 'Rhodes', 'plane_5');
insert into person values ('p25', 'Vincent', 'Garcia', 'plane_5');
insert into person values ('p26', 'Cheryl', 'Moore', 'plane_5');
insert into person values ('p27', 'Michael', 'Rivera', 'plane_8');
insert into person values ('p28', 'Luther', 'Matthews', 'plane_8');
insert into person values ('p29', 'Moses', 'Parks', 'plane_13');
insert into person values ('p30', 'Ora', 'Steele', 'plane_13');
insert into person values ('p31', 'Antonio', 'Flores', 'plane_13');
insert into person values ('p32', 'Glenn', 'Ross', 'plane_13');
insert into person values ('p33', 'Irma', 'Thomas', 'plane_20');
insert into person values ('p34', 'Ann', 'Maldonado', 'plane_20');
insert into person values ('p35', 'Jeffrey', 'Cruz', 'port_12');
insert into person values ('p36', 'Sonya', 'Price', 'port_12');
insert into person values ('p37', 'Tracy', 'Hale', 'port_12');
insert into person values ('p38', 'Albert', 'Simmons', 'port_14');
insert into person values ('p39', 'Karen', 'Terry', 'port_15');
insert into person values ('p40', 'Glen', 'Kelley', 'port_20');
insert into person values ('p41', 'Brooke', 'Little', 'port_3');
insert into person values ('p42', 'Daryl', 'Nguyen', 'port_4');
insert into person values ('p43', 'Judy', 'Willis', 'port_14');
insert into person values ('p44', 'Marco', 'Klein', 'port_15');
insert into person values ('p45', 'Angelica', 'Hampton', 'plane_26');
insert into person values ('p46', 'Peppermint', 'Patty', 'plane_26');
insert into person values ('p47', 'Charlie', 'Brown', 'plane_26');
insert into person values ('p48', 'Lucy', 'van Pelt', 'plane_27');
insert into person values ('p49', 'Linus', 'van Pelt', 'plane_27');

create table passenger (
	personID varchar(50),
    miles integer default 0,
    funds integer default 0,
    primary key (personID),
    constraint fk6 foreign key (personID) references person (personID)
) engine = innodb;

insert into passenger values ('p21', 771, 700);
insert into passenger values ('p22', 374, 200);
insert into passenger values ('p23', 414, 400);
insert into passenger values ('p24', 292, 500);
insert into passenger values ('p25', 390, 300);
insert into passenger values ('p26', 302, 600);
insert into passenger values ('p27', 470, 400);
insert into passenger values ('p28', 208, 400);
insert into passenger values ('p29', 292, 700);
insert into passenger values ('p30', 686, 500);
insert into passenger values ('p31', 547, 400);
insert into passenger values ('p32', 257, 500);
insert into passenger values ('p33', 564, 600);
insert into passenger values ('p34', 211, 200);
insert into passenger values ('p35', 233, 500);
insert into passenger values ('p36', 293, 400);
insert into passenger values ('p37', 552, 700);
insert into passenger values ('p38', 812, 700);
insert into passenger values ('p39', 541, 400);
insert into passenger values ('p40', 441, 700);
insert into passenger values ('p41', 875, 300);
insert into passenger values ('p42', 691, 500);
insert into passenger values ('p43', 572, 300);
insert into passenger values ('p44', 572, 500);
insert into passenger values ('p45', 663, 500);

create table passenger_vacations (
	personID varchar(50),
    airportID char(3) not null,
    sequence integer check (sequence > 0),
    primary key (personID, sequence),
    constraint fk19 foreign key (personID) references person (personID)
		on update cascade on delete cascade,
    constraint fk20 foreign key (airportID) references airport (airportID)
) engine = innodb;

insert into passenger_vacations values ('p21', 'AMS', 1);
insert into passenger_vacations values ('p22', 'AMS', 1);
insert into passenger_vacations values ('p23', 'BER', 1);
insert into passenger_vacations values ('p24', 'MUC', 1);
insert into passenger_vacations values ('p24', 'CDG', 2);
insert into passenger_vacations values ('p25', 'MUC', 1);
insert into passenger_vacations values ('p26', 'MUC', 1);
insert into passenger_vacations values ('p27', 'BER', 1);
insert into passenger_vacations values ('p28', 'LGW', 1);
insert into passenger_vacations values ('p29', 'FCO', 1);
insert into passenger_vacations values ('p29', 'LHR', 2);
insert into passenger_vacations values ('p30', 'FCO', 1);
insert into passenger_vacations values ('p30', 'MAD', 2);
insert into passenger_vacations values ('p31', 'FCO', 1);
insert into passenger_vacations values ('p32', 'FCO', 1);
insert into passenger_vacations values ('p33', 'CAN', 1);
insert into passenger_vacations values ('p34', 'HND', 1);
insert into passenger_vacations values ('p35', 'LGW', 1);
insert into passenger_vacations values ('p36', 'FCO', 1);
insert into passenger_vacations values ('p37', 'FCO', 1);
insert into passenger_vacations values ('p37', 'LGW', 2);
insert into passenger_vacations values ('p37', 'CDG', 3);
insert into passenger_vacations values ('p38', 'MUC', 1);
insert into passenger_vacations values ('p39', 'MUC', 1);
insert into passenger_vacations values ('p40', 'HND', 1);
insert into passenger_vacations values ('p45', 'ORD', 1);

create table leg (
	legID varchar(50),
    distance integer not null,
    departure char(3) not null,
    arrival char(3) not null,
    primary key (legID),
    constraint fk10 foreign key (departure) references airport (airportID),
    constraint fk11 foreign key (arrival) references airport (airportID)
) engine = innodb;

insert into leg values ('leg_1', 400, 'AMS', 'BER');
insert into leg values ('leg_2', 3900, 'ATL', 'AMS');
insert into leg values ('leg_3', 3700, 'ATL', 'LHR');
insert into leg values ('leg_4', 600, 'ATL', 'ORD');
insert into leg values ('leg_5', 500, 'BCN', 'CDG');
insert into leg values ('leg_6', 300, 'BCN', 'MAD');
insert into leg values ('leg_7', 4700, 'BER', 'CAN');
insert into leg values ('leg_8', 600, 'BER', 'LGW');
insert into leg values ('leg_9', 300, 'BER', 'MUC');
insert into leg values ('leg_10', 1600, 'CAN', 'HND');
insert into leg values ('leg_11', 500, 'CDG', 'BCN');
insert into leg values ('leg_12', 600, 'CDG', 'FCO');
insert into leg values ('leg_13', 200, 'CDG', 'LHR');
insert into leg values ('leg_14', 400, 'CDG', 'MUC');
insert into leg values ('leg_15', 200, 'DFW', 'IAH');
insert into leg values ('leg_16', 800, 'FCO', 'MAD');
insert into leg values ('leg_17', 300, 'FRA', 'BER');
insert into leg values ('leg_18', 100, 'HND', 'NRT');
insert into leg values ('leg_19', 300, 'HOU', 'DFW');
insert into leg values ('leg_20', 100, 'IAH', 'HOU');
insert into leg values ('leg_21', 600, 'LGW', 'BER');
insert into leg values ('leg_22', 600, 'LHR', 'BER');
insert into leg values ('leg_23', 500, 'LHR', 'MUC');
insert into leg values ('leg_24', 300, 'MAD', 'BCN');
insert into leg values ('leg_25', 600, 'MAD', 'CDG');
insert into leg values ('leg_26', 800, 'MAD', 'FCO');
insert into leg values ('leg_27', 300, 'MUC', 'BER');
insert into leg values ('leg_28', 400, 'MUC', 'CDG');
insert into leg values ('leg_29', 400, 'MUC', 'FCO');
insert into leg values ('leg_30', 200, 'MUC', 'FRA');
insert into leg values ('leg_31', 3700, 'ORD', 'CDG');

create table route (
	routeID varchar(50),
    primary key (routeID)
) engine = innodb;

insert into route values ('euro_north');
insert into route values ('euro_south');
insert into route values ('south_euro_loop');
insert into route values ('big_europe_loop');
insert into route values ('americas_one');
insert into route values ('americas_two');
insert into route values ('americas_three');
insert into route values ('pacific_rim_tour');
insert into route values ('germany_local');
insert into route values ('texas_local');
insert into route values ('americas_hub_exchange');

create table route_path (
	routeID varchar(50),
    legID varchar(50) not null,
    sequence integer check (sequence > 0),
    primary key (routeID, sequence),
    constraint fk12 foreign key (routeID) references route (routeID),
    constraint fk13 foreign key (legID) references leg (legID)
) engine = innodb;

insert into route_path values ('euro_north', 'leg_16', 1);
insert into route_path values ('euro_north', 'leg_24', 2);
insert into route_path values ('euro_north', 'leg_5', 3);
insert into route_path values ('euro_north', 'leg_14', 4);
insert into route_path values ('euro_north', 'leg_27', 5);
insert into route_path values ('euro_north', 'leg_8', 6);
insert into route_path values ('euro_south', 'leg_21', 1);
insert into route_path values ('euro_south', 'leg_9', 2);
insert into route_path values ('euro_south', 'leg_28', 3);
insert into route_path values ('euro_south', 'leg_11', 4);
insert into route_path values ('euro_south', 'leg_6', 5);
insert into route_path values ('euro_south', 'leg_26', 6);
insert into route_path values ('south_euro_loop', 'leg_16', 1);
insert into route_path values ('south_euro_loop', 'leg_24', 2);
insert into route_path values ('south_euro_loop', 'leg_5', 3);
insert into route_path values ('south_euro_loop', 'leg_12', 4);
insert into route_path values ('big_europe_loop', 'leg_23', 1);
insert into route_path values ('big_europe_loop', 'leg_29', 2);
insert into route_path values ('big_europe_loop', 'leg_16', 3);
insert into route_path values ('big_europe_loop', 'leg_25', 4);
insert into route_path values ('big_europe_loop', 'leg_13', 5);
insert into route_path values ('americas_one', 'leg_2', 1);
insert into route_path values ('americas_one', 'leg_1', 2);
insert into route_path values ('americas_two', 'leg_3', 1);
insert into route_path values ('americas_two', 'leg_22', 2);
insert into route_path values ('americas_three', 'leg_31', 1);
insert into route_path values ('americas_three', 'leg_14', 2);
insert into route_path values ('pacific_rim_tour', 'leg_7', 1);
insert into route_path values ('pacific_rim_tour', 'leg_10', 2);
insert into route_path values ('pacific_rim_tour', 'leg_18', 3);
insert into route_path values ('germany_local', 'leg_9', 1);
insert into route_path values ('germany_local', 'leg_30', 2);
insert into route_path values ('germany_local', 'leg_17', 3);
insert into route_path values ('texas_local', 'leg_15', 1);
insert into route_path values ('texas_local', 'leg_20', 2);
insert into route_path values ('texas_local', 'leg_19', 3);
insert into route_path values ('americas_hub_exchange', 'leg_4', 1);

create table flight (
	flightID varchar(50),
    routeID varchar(50) not null,
    support_airline varchar(50) default null,
    support_tail varchar(50) default null,
    progress integer default null,
    airplane_status varchar(100) default null,
    next_time time default null,
    cost integer default 0,
	primary key (flightID),
    constraint fk14 foreign key (routeID) references route (routeID) on update cascade,
    constraint fk15 foreign key (support_airline, support_tail) references airplane (airlineID, tail_num)
		on update cascade on delete cascade
) engine = innodb;

insert into flight values ('dl_10', 'americas_one', 'Delta', 'n106js', 1, 'in_flight', '08:00:00', 200);
insert into flight values ('un_38', 'americas_three', 'United', 'n380sd', 2, 'in_flight', '14:30:00', 200);
insert into flight values ('ba_61', 'americas_two', 'British Airways', 'n616lt', 0, 'on_ground', '09:30:00', 200);
insert into flight values ('lf_20', 'euro_north', 'Lufthansa', 'n620la', 3, 'on_ground', '11:00:00', 300);
insert into flight values ('km_16', 'euro_south', 'KLM', 'n161fk', 6, 'in_flight', '14:00:00', 400);
insert into flight values ('ba_51', 'big_europe_loop', 'British Airways', 'n517ly', 0, 'on_ground', '11:30:00', 100);
insert into flight values ('ja_35', 'pacific_rim_tour', 'Japan Airlines', 'n305fv', 1, 'in_flight', '09:30:00', 300);
insert into flight values ('ry_34', 'germany_local', 'Ryanair', 'n341eb', 0, 'on_ground', '15:00:00', 100);
insert into flight values ('am_96', 'americas_hub_exchange', 'American', 'n225sb', 1, 'on_ground', '21:30:00', 100);
insert into flight values ('am_99', 'americas_hub_exchange', 'American', 'n553qn', 1, 'on_ground', '21:00:00', 100);
insert into flight values ('am_86', 'south_euro_loop', 'Air France', 'n118fm', 4, 'on_ground', '23:45:00', 100);

create table pilot (
	personID varchar(50),
    taxID varchar(50) not null,
    experience integer default 0,
    commanding_flight varchar(50) default null,
    primary key (personID),
    unique key (taxID),
    constraint fk4 foreign key (personID) references person (personID),
    constraint fk9 foreign key (commanding_flight) references flight (flightID)
) engine = innodb;

insert into pilot values ('p1', '330-12-6907', 31, 'dl_10');
insert into pilot values ('p2', '842-88-1257', 9, 'dl_10');
insert into pilot values ('p3', '750-24-7616', 11, 'un_38');
insert into pilot values ('p4', '776-21-8098', 24, 'un_38');
insert into pilot values ('p5', '933-93-2165', 27, 'ba_61');
insert into pilot values ('p6', '707-84-4555', 38, 'ba_61');
insert into pilot values ('p7', '450-25-5617', 13, 'lf_20');
insert into pilot values ('p8', '701-38-2179', 12, 'ry_34');
insert into pilot values ('p9', '936-44-6941', 13, 'lf_20');
insert into pilot values ('p10', '769-60-1266', 15, 'lf_20');
insert into pilot values ('p11', '369-22-9505', 22, 'km_16');
insert into pilot values ('p12', '680-92-5329', 24, 'ry_34');
insert into pilot values ('p13', '513-40-4168', 24, 'km_16');
insert into pilot values ('p14', '454-71-7847', 13, 'km_16');
insert into pilot values ('p15', '153-47-8101', 30, 'ja_35');
insert into pilot values ('p16', '598-47-5172', 28, 'ja_35');
insert into pilot values ('p17', '865-71-6800', 36, null);
insert into pilot values ('p18', '250-86-2784', 23, null);
insert into pilot values ('p19', '386-39-7881', 2, null);
insert into pilot values ('p20', '522-44-3098', 28, null);
insert into pilot values ('p46', '523-45-3098', 28, 'am_96');
insert into pilot values ('p47', '524-46-3198', 28, 'am_96');
insert into pilot values ('p48', '525-47-3298', 28, 'am_99');
insert into pilot values ('p49', '526-48-3398', 28, 'am_99');

create table pilot_licenses (
	personID varchar(50),
    license varchar(100),
    primary key (personID, license),
    constraint fk5 foreign key (personID) references pilot (personID)
		on update cascade on delete cascade
) engine = innodb;

insert into pilot_licenses values ('p1', 'jets');
insert into pilot_licenses values ('p2', 'jets');
insert into pilot_licenses values ('p2', 'props');
insert into pilot_licenses values ('p3', 'jets');
insert into pilot_licenses values ('p4', 'jets');
insert into pilot_licenses values ('p4', 'props');
insert into pilot_licenses values ('p5', 'jets');
insert into pilot_licenses values ('p6', 'jets');
insert into pilot_licenses values ('p6', 'props');
insert into pilot_licenses values ('p7', 'jets');
insert into pilot_licenses values ('p8', 'props');
insert into pilot_licenses values ('p9', 'props');
insert into pilot_licenses values ('p9', 'jets');
insert into pilot_licenses values ('p9', 'testing');
insert into pilot_licenses values ('p10', 'jets');
insert into pilot_licenses values ('p11', 'jets');
insert into pilot_licenses values ('p11', 'props');
insert into pilot_licenses values ('p12', 'props');
insert into pilot_licenses values ('p13', 'jets');
insert into pilot_licenses values ('p14', 'jets');
insert into pilot_licenses values ('p15', 'jets');
insert into pilot_licenses values ('p15', 'props');
insert into pilot_licenses values ('p15', 'testing');
insert into pilot_licenses values ('p16', 'jets');
insert into pilot_licenses values ('p17', 'jets');
insert into pilot_licenses values ('p17', 'props');
insert into pilot_licenses values ('p18', 'jets');
insert into pilot_licenses values ('p19', 'jets');
insert into pilot_licenses values ('p20', 'jets');
insert into pilot_licenses values ('p46', 'jets');
insert into pilot_licenses values ('p47', 'jets');
insert into pilot_licenses values ('p48', 'jets');
insert into pilot_licenses values ('p49', 'jets');
