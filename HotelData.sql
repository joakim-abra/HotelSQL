USE Hotel;
GO

-- Anställda
insert into Employees (first_name, last_name, position) values ('Kim', 'Grellier', 'Reception');
insert into Employees (first_name, last_name, position) values ('Susana', 'Petrus', 'Booking manager');
insert into Employees (first_name, last_name, position) values ('Kiersten', 'Gravet', 'Reception');
insert into Employees (first_name, last_name, position) values ('Tonie', 'Pochin', 'Reception');
insert into Employees (first_name, last_name, position) values ('Andie', 'Charlon', 'Reception');
insert into Employees (first_name, last_name, position) values ('Claudian', 'Daingerfield', 'Reception');
insert into Employees (first_name, last_name, position) values ('Silvia', 'Eathorne', 'Reception');
insert into Employees (first_name, last_name, position) values ('Delmore', 'Toffoloni', 'Reception');
insert into Employees (first_name, last_name, position) values ('Aubrey', 'Willey', 'Reception');
insert into Employees (first_name, last_name, position) values ('Constantin', 'Moffat', 'Reception');

-- Gäster
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Lane', 'Bakes', 'lbakes0@aboutads.info', '837-379-8776', '80 Reindahl Place', 'Singaparna', null, 'Indonesia');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Marty', 'Ovanesian', 'movanesian1@eventbrite.com', '210-102-5720', '3 Westerfield Court', 'Song', '54120', 'Thailand');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Barbra', 'Rothery', 'brothery2@businessweek.com', '587-509-8096', '14 Haas Junction', 'Longtian', null, 'China');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Grove', 'Boynes', 'gboynes3@wikispaces.com', '603-592-6012', '12 Northwestern Way', 'Mozhga', '445560', 'Russia');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Merl', 'Darrow', 'mdarrow4@sina.com.cn', '148-728-7499', '97 Sutteridge Drive', 'Sanlidian', null, 'China');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Bartholomeo', 'McAllister', 'bmcallister5@hugedomains.com', '515-427-5827', '1 Blue Bill Park Lane', 'Jinxiu', null, 'China');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Lem', 'Gurney', 'lgurney6@networkadvertising.org', '923-596-6301', '45050 Loftsgordon Point', 'Usab', '6127', 'Philippines');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Shanda', 'Cubbit', 'scubbit7@bloomberg.com', '667-243-8901', '1 Birchwood Park', 'Dong Charoen', '66210', 'Thailand');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Roxanna', 'Shury', 'rshury8@examiner.com', '739-915-2202', '4 Crescent Oaks Plaza', 'Devin', '4815', 'Bulgaria');
insert into Customer (first_name, last_name, email, phone_number, street_address, city, postal_code, country) values ('Anastasie', 'Sabatini', 'asabatini9@toplist.cz', '905-889-2959', '2333 Holmberg Pass', 'Volokonovka', '457151', 'Russia');

-- Kreditkort
INSERT INTO creditcard (card_type) VALUES ('American Express');
INSERT INTO creditcard (card_type) VALUES ('Bankcard');
INSERT INTO creditcard (card_type) VALUES ('Diners Club');
INSERT INTO creditcard (card_type) VALUES ('InstaPayment');
INSERT INTO creditcard (card_type) VALUES ('JCB');
INSERT INTO creditcard (card_type) VALUES ('Laser');
INSERT INTO creditcard (card_type) VALUES ('Mastercard');
INSERT INTO creditcard (card_type) VALUES ('Mestro');
INSERT INTO creditcard (card_type) VALUES ('Solo');
INSERT INTO creditcard (card_type) VALUES ('Switch');
INSERT INTO creditcard (card_type) VALUES ('Visa');
GO



