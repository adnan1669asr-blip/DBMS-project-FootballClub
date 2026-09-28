-- 1. Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS FOOTBALLMANAGMENT;

-- 2. Select the database
USE FOOTBALLMANAGMENT;

-- 3. Disable foreign key checks to drop tables safely
SET FOREIGN_KEY_CHECKS = 0;

-- Drop relational/junction tables first
DROP TABLE IF EXISTS PARTICIPATESIN;
DROP TABLE IF EXISTS LOCATEDIN;
DROP TABLE IF EXISTS HASSPONSOR;
DROP TABLE IF EXISTS GIVENBY;
DROP TABLE IF EXISTS WINSAWARD;
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS UserFan;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS Tickets;
DROP TABLE IF EXISTS Merchandise;
DROP TABLE IF EXISTS News;
DROP VIEW IF EXISTS footballmanagment_game;

-- Drop entity tables next
DROP TABLE IF EXISTS COACH;
DROP TABLE IF EXISTS REFEREE;
DROP TABLE IF EXISTS AWARDS;
DROP TABLE IF EXISTS SPONSOR;
DROP TABLE IF EXISTS INJURY;
DROP TABLE IF EXISTS STATISTICS;
DROP TABLE IF EXISTS ATHLETE;
DROP TABLE IF EXISTS TEAM;
DROP TABLE IF EXISTS VENUE;
DROP TABLE IF EXISTS GAME;

-- Drop details tables last
DROP TABLE IF EXISTS POSITIONDETAILS;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

/* Entities */
CREATE TABLE Venue(
	venue_address varchar(100),
	venue_name varchar(100) UNIQUE,
	capacity int,
	PRIMARY KEY(venue_address)
);

CREATE TABLE IF NOT EXISTS Team(
    team_name VARCHAR(100) PRIMARY KEY,
    coach_name VARCHAR(100),
    home_venues VARCHAR(100) NOT NULL,
    FOREIGN KEY(home_venues) REFERENCES Venue(venue_address)
);

CREATE TABLE IF NOT EXISTS PositionDetails (
    PositionID INT PRIMARY KEY,
    PositionName VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Athlete (
    person_id INT PRIMARY KEY,
    name VARCHAR(100),
    birthdate DATE,
    height FLOAT,
    weight FLOAT,
    phone_number BIGINT UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(100),
    date_started DATE,
    jersey_num INT,
    current_team VARCHAR(100) NOT NULL,
    salary INT,
    FOREIGN KEY (current_team) REFERENCES Team(team_name),
    FOREIGN KEY (jersey_num) REFERENCES PositionDetails(PositionID)
        ON DELETE CASCADE
);


CREATE TABLE Coach(
    person_id int PRIMARY KEY,
    name varchar(100),
    birthdate date,
    height float,
    weight float,
    phone_number bigint UNIQUE,
    email varchar(100) UNIQUE,
    address varchar(100),
    date_started date,
    current_team varchar(100) NOT NULL,
    specialization varchar(100),
    FOREIGN KEY(current_team) REFERENCES Team(team_name)
);

CREATE TABLE Referee(
	person_id int,
	name varchar(100),
	birthdate date,
	height float,
	weight float,
	phone_number bigint UNIQUE,
	email varchar(100) UNIQUE,
	address varchar(100),
	date_started date,
	certification_level int,
    PRIMARY KEY(person_id)
);

CREATE TABLE IF NOT EXISTS Game (
    game_id INT PRIMARY KEY,
    home VARCHAR(100),
    away VARCHAR(100),
    game_date DATE
);

-- Create Statistics table
CREATE TABLE IF NOT EXISTS Statistics (
    stats_id INT PRIMARY KEY,
    person_id INT NOT NULL,
    game_id INT NOT NULL,
    goals INT,
    shots_taken INT,
    passes_attempted INT,
    turnovers INT,
    possession_percent FLOAT,
    FOREIGN KEY (person_id) REFERENCES Athlete(person_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES Game(game_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS Awards (
    award_id INT PRIMARY KEY,
    year INT,
    award_name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Sponsor (
    sponsor_name VARCHAR(100) PRIMARY KEY,
    sponsor_email VARCHAR(100) UNIQUE,
    money_granted INT
);


CREATE TABLE IF NOT EXISTS Injury (
    injury_type VARCHAR(100),
    injury_date DATE,
    injury_status INT,  /* 0 = false, other = true */
    person_id INT,
    PRIMARY KEY (person_id, injury_type, injury_date),
    FOREIGN KEY (person_id) REFERENCES Athlete(person_id)
        ON DELETE CASCADE
);


/* Relationship Tables */

CREATE TABLE ParticipatesIn(
    game_id int,
    team_1 varchar(100),
    team_2 varchar(100),
    PRIMARY KEY(game_id),
    FOREIGN KEY(team_1) REFERENCES Team(team_name) ON DELETE CASCADE,
    FOREIGN KEY(team_2) REFERENCES Team(team_name) ON DELETE CASCADE,
    FOREIGN KEY(game_id) REFERENCES Game(game_id) ON DELETE CASCADE
);


CREATE TABLE LocatedIn(
    game_id int,
    venue_address varchar(100),
    PRIMARY KEY(game_id, venue_address),
    FOREIGN KEY(game_id) REFERENCES Game(game_id) ON DELETE CASCADE,
    FOREIGN KEY(venue_address) REFERENCES Venue(venue_address) ON DELETE CASCADE
);
CREATE TABLE HasSponsor(
    team_name varchar(100),
    sponsor_name varchar(100),
    PRIMARY KEY(team_name, sponsor_name),
    FOREIGN KEY(team_name) REFERENCES Team(team_name) ON DELETE CASCADE,
    FOREIGN KEY(sponsor_name) REFERENCES Sponsor(sponsor_name) ON DELETE CASCADE
);

CREATE TABLE GivenBy(
    sponsor_name varchar(100),
    award_id int,
    PRIMARY KEY(sponsor_name, award_id),
    FOREIGN KEY(sponsor_name) REFERENCES Sponsor(sponsor_name) ON DELETE CASCADE,
    FOREIGN KEY(award_id) REFERENCES Awards(award_id) ON DELETE CASCADE
);

CREATE TABLE WinsAward(
    award_id int,
    person_id int,
    team_name varchar(100),
    PRIMARY KEY(award_id),
    FOREIGN KEY(award_id) REFERENCES Awards(award_id) ON DELETE CASCADE,
    FOREIGN KEY(person_id) REFERENCES Athlete(person_id) ON DELETE CASCADE,
    FOREIGN KEY(team_name) REFERENCES Team(team_name) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Referees(
    person_id int,
    game_id int,
    PRIMARY KEY(person_id, game_id),
    FOREIGN KEY(person_id) REFERENCES Referee(person_id) ON DELETE CASCADE,
    FOREIGN KEY(game_id) REFERENCES Game(game_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user'
);

CREATE TABLE IF NOT EXISTS UserFan (
    fan_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100),
    email VARCHAR(255),
    password VARCHAR(255),
    favorite_team VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (favorite_team) REFERENCES Team(team_name) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    order_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    paid_at DATETIME NULL,
    confirmed_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_name VARCHAR(150) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT,
    seat_number VARCHAR(30),
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'available',
    FOREIGN KEY (game_id) REFERENCES Game(game_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Merchandise (
    merchandise_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    stock INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS News (
    news_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    published_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE VIEW footballmanagment_game AS
SELECT game_id, home, away, game_date
FROM Game;


-- Insert into PositionDetails
INSERT INTO PositionDetails (PositionID, PositionName) VALUES
(1, 'Goalkeeper'),
(2, 'Right Back'),
(3, 'Left Back'),
(4, 'Sweeper'),
(5, 'Central Back'),
(6, 'Defensive Midfielder'),
(7, 'Winger'),
(8, 'Central Midfielder'),
(9, 'Striker'),
(10, 'Central Attacking Midfielder'),
(11, 'Outside Midfielder');

-- Insert into Venue
INSERT INTO Venue (venue_address, Venue_name, Capacity) VALUES
('5123 Main Street, Vancouver', 'Benz Stadium', 10000),
('5456 Oak Avenue, Richmond', 'Mountain View Stadium', 20000),
('5789 Elm Road, Burnaby', 'Evergreen Arena', 15000),
('5101 Maple Lane, Surrey', 'Harbor View Stadium', 5000),
('5234 Pine Street, Coquitlam', 'Sea View Arena', 34500),
('1923 River Road, Langley', 'Waterways Stadium', 17000);

-- Insert into Team
INSERT INTO Team (team_name, coach_name, home_venues) VALUES
('Vancouver Vipers', 'John Wong', '5123 Main Street, Vancouver'),
('Richmond Thunder', 'Emily Johnson', '5456 Oak Avenue, Richmond'),
('Burnaby Warriors', 'Michael Brown', '5789 Elm Road, Burnaby'),
('Surrey Titans', 'Sarah Lee', '5101 Maple Lane, Surrey'),
('Coquitlam Sharks', 'Robert Davis', '5234 Pine Street, Coquitlam'),
('Langley Bears', 'Chris Huk', '1923 River Road, Langley');

INSERT INTO Athlete 
(person_id, name, birthdate, height, weight, phone_number, email, address, date_started, jersey_num, current_team, salary) 
VALUES
-- Vancouver Vipers
(1, 'John Doe', '1989-12-05', 178, 77, 6041234567, 'john.doe@soccer.com', '123 Main St, Vancouver', '2006-11-30', 1, 'Vancouver Vipers', 60000),
(2, 'Jane Smith', '1993-04-30', 170, 68, 8778980912, 'jane.smith@soccer.com', '123 Oak St, Vancouver', '2014-09-07', 2, 'Vancouver Vipers', 70000),
(3, 'Mike Johnson', '1980-06-14', 188, 91, 6041820192, 'mike.johnson@soccer.com', '461 Fir St, Vancouver', '2000-04-18', 3, 'Vancouver Vipers', 120000),
(4, 'Michelle Zhu', '1987-02-09', 178, 82, 7781920391, 'michell.zhu@soccer.com', '192 Oats Rd, Vancouver', '2010-10-10', 4, 'Vancouver Vipers', 100000),
(5, 'Michael Dune', '1993-09-12', 203, 132, 6045129102, 'michael.dune@soccer.com', '101 Chem Drive, Vancouver', '2011-03-18', 5, 'Vancouver Vipers', 500000),
(6, 'Serena Storm', '1985-11-20', 170, 56, 7889129301, 'serena.storm@soccer.com', '783 Balsam St, Vancouver', '2005-02-05', 6, 'Vancouver Vipers', 190000),
(7, 'Daniel Kee', '1991-07-06', 178, 76, 6045919203, 'daniel.kee@soccer.com', '912 Mark Lane, Vancouver', '2018-08-14', 7, 'Vancouver Vipers', 1200000),
(8, 'Emily Carr', '1988-03-19', 170, 86, 8778902183, 'emily.carr@soccer.com', '281 Fox St, Vancouver', '2002-12-22', 8, 'Vancouver Vipers', 80000),
(9, 'Jason Bills', '1996-05-02', 130, 39, 7781029301, 'jason.bills@soccer.com', '292 Blue Drive, Vancouver', '2015-12-30', 9, 'Vancouver Vipers', 180000),
(10, 'Rachel Jordan', '1982-07-16', 175, 67, 6045881923, 'rachel.jordan@soccer.com', '778 Phone St, Vancouver', '2004-06-03', 10, 'Vancouver Vipers', 175000),
(11, 'Rick Tord', '1998-11-25', 183, 78, 7786758192, 'rick.tord@soccer.com', '182 Dubious Lane, Vancouver', '2009-07-12', 11, 'Vancouver Vipers', 250000),

    -- Richmond Thunder
(12, 'Billy Bob', '1981-01-03', 198, 127, 6045557892, 'billy.bob@socer.com', '872 Fire Lane, Vancouver', '2007-09-27', 1, 'Richmond Thunder', 280000),
(13, 'Danielle Chu', '1994-06-28', 163, 56, 7789901203, 'danielle.chu@soccer.com', '897 Key St, Vancouver', '2013-04-19', 2, 'Richmond Thunder', 3400000),
(14, 'Darren Sam', '1989-08-11', 185, 84, 6045589102, 'darren.sam@soccer.com', '291 Bin Rd, Vancouver', '2001-08-09', 3, 'Richmond Thunder', 120000),
(15, 'Cynthia Game', '1995-12-14', 168, 59, 6049012930, 'cynthia.game@soccer.com', '448 Elm Rd, Vancouver', '2016-01-07', 4, 'Richmond Thunder', 190000),
(16, 'Mark Nguyen', '1984-02-28', 185, 82, 7781920192, 'mark.nguyen@soccer.com', '909 Flower Dr, Vancouver', '2003-09-14', 5, 'Richmond Thunder', 1700000),
(17, 'Jillian Prim', '1990-04-10', 173, 51, 6047781029, 'jillian.prim@soccer.com', '180 Priority St, Vancouver', '2019-02-21', 6, 'Richmond Thunder', 2000000),
(18, 'Simon Jones', '1986-10-21', 216, 44, 7786521829, 'simon.jones@soccer.com', '728 Current Dr, Vancouver', '2006-07-16', 7, 'Richmond Thunder', 70000),
(19, 'Adora Park', '1992-02-03', 157, 45, 6045781029, 'adora.park@soccer.com', '182 Princeton Way, Vancouver', '2009-05-14', 8, 'Richmond Thunder', 900000),
(20, 'Matt Dracos', '1983-08-26', 198, 94, 7785648189, 'matt.dracos@soccer.com', '994 Slogan Dr, Vancouver', '2017-08-25', 9, 'Richmond Thunder', 90000),
(21, 'Heidi Gram', '1997-01-09', 173, 36, 6048891203, 'heidi.gram@soccer.com', '444 Dragon Rd, Vancouver', '2006-04-30', 10, 'Richmond Thunder', 170000),
(22, 'Jeremy Lim', '1980-12-23', 170, 67, 7786541092, 'jeremy.lim@soccer.com', '182 Basket Way, Vancouver', '2014-11-07', 11, 'Richmond Thunder', 240000),
   -- Burnaby Warriors
(23, 'Parker Fin', '1986-04-17', 168, 53, 6057810293, 'parker.fin@soccer.com', '982 Bingo St, Vancouver', '2000-11-18', 1, 'Burnaby Warriors', 170000),
(24, 'Lauren Shim', '1992-09-15', 163, 40, 8778718211, 'lauren.shim@soccer.com', '821 Heart Way, Vancouver', '2008-10-01', 2, 'Burnaby Warriors', 256000),
(25, 'Markus Duff', '1988-11-23', 203, 86, 6045579012, 'markus.duff@soccer.com', '192 Rock Lane, Vancouver', '2012-06-12', 3, 'Burnaby Warriors', 400000),
(26, 'Fiora Moon', '1995-07-09', 170, 64, 7786541297, 'fiora.moon@soccer.com', '872 Piano Dr, Vancouver', '2005-08-23', 4, 'Burnaby Warriors', 187000),
(27, 'Wolf Sun', '1982-03-26', 107, 61, 6045709908, 'wolf.sun@soccer.com', '126 Error Rd, Vancouver', '2017-04-05', 5, 'Burnaby Warriors', 80000),
(28, 'MJ Heart', '1998-06-12', 168, 45, 7781112345, 'mj.heart@soccer.com', '988 Nest Way, Vancouver', '2003-02-14', 6, 'Burnaby Warriors', 190000),
(29, 'Jordan Tan', '1987-08-28', 229, 70, 6048990765, 'jordan.tan@soccer.com', '444 Bike Lane, Vancouver', '2014-10-30', 7, 'Burnaby Warriors', 761000),
(30, 'Ellie Howling', '1990-02-15', 115, 40, 7789912232, 'ellie.howling@soccer.com', '291 Desk Rd, Vancouver', '2009-03-01', 8, 'Burnaby Warriors', 19000),
(31, 'Darius Wong', '1986-12-21', 216, 77, 7786098801, 'darius.wong@soccer.com', '321 Turn St, Vancouver', '2006-09-20', 9, 'Burnaby Warriors', 172000),
(32, 'Delilah Kim', '1994-05-06', 168, 36, 6045578901, 'delilah.kim@soccer.com', '124 Function Rd, Vancouver', '2010-12-10', 10, 'Burnaby Warriors', 900000),
(33, 'Francis David', '1983-07-01', 201, 101, 7786543389, 'francis.david@soccer.com', '127 Bacon St, Vancouver', '2001-01-15', 11, 'Burnaby Warriors', 876000),
	-- Surrey Titans
-- Surrey Titans
(34, 'Adam Desmond', '1997-11-13', 178, 65, 6045578896, 'adam.desmond@soccer.com', '778 Philosophy Lane, Vancouver', '2015-07-17', 1, 'Surrey Titans', 178000),
(35, 'Brittany Peterson', '1981-01-27', 137, 59, 7786129993, 'brittany.peterson@soccer.com', '560 Canuck St, Vancouver', '2004-11-08', 2, 'Surrey Titans', 200000),
(36, 'Ryan Son', '1999-03-10', 231, 84, 6046678901, 'ryan.son@soccer.com', '329 Jensen Way, Vancouver', '2018-06-25', 3, 'Surrey Titans', 678000),
(37, 'Georgia Cheng', '1984-07-21', 180, 59, 8778019812, 'georgia.cheng@soccer.com', '008 Armour Dr, Vancouver', '2007-03-03', 4, 'Surrey Titans', 192000),
(38, 'Jared Sinew', '1991-04-03', 196, 139, 6040580095, 'jared.sinew@soccer.com', '776 Corpus Lane, Vancouver', '2012-08-14', 5, 'Surrey Titans', 70800),
(39, 'Ashley Shu', '1996-09-17', 168, 54, 7783220119, 'ashley.shu@soccer.com', '887 Compass Rd, Vancouver', '2002-05-20', 6, 'Surrey Titans', 1000000),
(40, 'Lucas Man', '1989-12-30', 203, 38, 6048571002, 'lucas.man@soccer.com', '812 Lead Dr, Vancouver', '2016-04-09', 7, 'Surrey Titans', 240000),
(41, 'Sherry Van', '1993-05-15', 188, 50, 7780091435, 'sherry.van@soccer.com', '441 Floor Rd, Vancouver', '2008-01-12', 8, 'Surrey Titans', 700000),
(42, 'Vincent Lu', '1980-07-29', 178, 43, 6044478990, 'vincent.lu@soccer.com', '128 Douglas Dr, Vancouver', '2011-09-27', 9, 'Surrey Titans', 860000),
(43, 'Mary Jane', '1987-02-27', 180, 49, 7787563299, 'mary.jane@soccer.com', '888 Thunder Rd, Vancouver', '2005-06-22', 10, 'Surrey Titans', 978000),
(44, 'Jason Billy', '1993-09-20', 180, 57, 6049890071, 'jason.billy@soccer.com', '449 Apple St, Vancouver', '2017-01-05', 11, 'Surrey Titans', 170000),

	-- Coquitlam Sharks
(45, 'Harry Ford', '1985-11-18', 188, 71, 7786543090, 'harry.ford@soccer.com', '192 Falcon Dr, Vancouver', '2003-12-14', 1, 'Coquitlam Sharks', 16700000),
(46, 'Ruth North', '1991-07-12', 137, 149, 6045589012, 'ruth.north@soccer.com', '514 Fox Way, Vancouver', '2014-07-30', 2, 'Coquitlam Sharks', 40000),
(47, 'Luke Sky', '1988-03-25', 203, 241, 7786543998, 'luke.sky@soccer.com', '123 Force Lane, Vancouver', '2009-05-01', 3, 'Coquitlam Sharks', 990000),
(48, 'Noon Locomotion', '1996-05-18', 137, 68, 7780091002, 'noon.locomotion@soccer.com', '443 Train Rd, Vancouver', '2006-10-20', 4, 'Coquitlam Sharks', 54600),
(49, 'Parker Jones', '1982-07-26', 178, 190, 6041123009, 'parker.jones@soccer.com', '652 Stone Lane, Vancouver', '2011-01-10', 5, 'Coquitlam Sharks', 981000),
(50, 'Jamie Flame', '1998-11-27', 180, 167, 7784439012, 'jamie.flame@soccer.com', '332 Yang St, Vancouver', '2001-02-15', 6, 'Coquitlam Sharks', 728000),
(51, 'Dennis Honda', '1981-01-09', 195, 136, 6045589900, 'dennis.honda@soccer.com', '126 Arch Way, Vancouver', '2015-08-17', 7, 'Coquitlam Sharks', 971000),
(52, 'Karina Allen', '1994-07-27', 178, 94, 7786519822, 'karina.allen@soccer.com', '349 Synchronization Lane, Vancouver', '2004-12-08', 8, 'Coquitlam Sharks', 144000),
(53, 'John Under', '1989-09-15', 146, 119, 6045567124, 'john.under@soccer.com', '448 Dream Rd, Vancouver', '2018-07-25', 9, 'Coquitlam Sharks', 322900),
(54, 'Alicia Yoo', '1995-11-18', 168, 120, 7781129945, 'alicia.yoo@soccer.com', '229 Ocean Rd, Vancouver', '2007-04-03', 10, 'Coquitlam Sharks', 890000),
(55, 'Cameron Jonas', '1984-03-30', 185, 146, 7781009020, 'cameron.jones@soccer.com', '776 Sting St, Vancouver', '2012-09-14', 11, 'Coquitlam Sharks', 750000),
	-- Langley Bears
	(56, 'James Fort', '1990-07-17', 210, 156, 6049125567, 'james.fort@soccer.com', '554 Knob Rd, Vancouver', '2002-06-20', 1, 'Langley Bears', 150000),
(57, 'Ivana Lee', '1986-09-02', 137, 144, 7786990001, 'ivana.lee@soccer.com', '447 Jelly Way, Vancouver', '2016-05-09', 2, 'Langley Bears', 800000),
(58, 'Jim Gear', '1992-02-04', 180, 239, 6045578990, 'jim.gear@soccer.com', '761 Willow Drive, Vancouver', '2008-02-12', 3, 'Langley Bears', 60000),
(59, 'Sophia Turn', '1983-08-23', 163, 129, 8786654888, 'sophia.turn@soccer.com', '551 Sunflower Way, Vancouver', '2011-10-27', 4, 'Langley Bears', 765000),
(60, 'Andrew Lim', '1997-01-19', 196, 178, 6049980073, 'andrew.lim@soccer.com', '060 Focus St, Vancouver', '2005-07-22', 5, 'Langley Bears', 236000),
(61, 'Evelyn Crow', '1980-12-03', 137, 144, 7786527778, 'evelyn.crow@soccer.com', '445 Gold Lane, Vancouver', '2017-02-05', 6, 'Langley Bears', 743000),
(62, 'Tim Shore', '1986-04-15', 203, 345, 6045590087, 'tim.shore@soccer.com', '112 Plane Rd, Vancouver', '2004-01-14', 7, 'Langley Bears', 76500),
(63, 'Rebecca Salvador', '1992-09-30', 157, 100, 6048891112, 'rebecca.salvador@soccer.com', '887 Leaf Way, Vancouver', '2015-07-30', 8, 'Langley Bears', 106700),
(64, 'Jean Fargo', '1988-11-07', 168, 178, 7782234778, 'jean.fargo@soccer.com', '119 Boar Dr, Vancouver', '2010-05-01', 9, 'Langley Bears', 178000),
(65, 'Selena An', '1995-07-12', 144, 110, 6045009122, 'selena.an@soccer.com', '132 Stores Way, Vancouver', '2006-11-20', 10, 'Langley Bears', 1780000),
(66, 'Ahmed Tom', '1982-03-06', 188, 143, 7786223489, 'ahmed.tom@soccer.com', '443 Manager St. Vancouver', '2011-02-10', 11, 'Langley Bears', 166500),

    -- Injured Athletes
    (67, 'Simon Fraser', '1988-07-12', 121, 106, 6049175567, 'simon.fraser@soccer.com', '888 Machine Rd, Vancouver', '2012-06-23', 1, 'Langley Bears', 170000),
(68, 'Marie So', '2000-09-02', 181, 145, 7786990101, 'marie.so@soccer.com', '409 Pillar Lane, Vancouver', '2016-08-08', 2, 'Langley Bears', 600000),
(69, 'Jayden Jay', '1998-12-04', 209, 59, 6045579990, 'jayden.jay@soccer.com', '561 Heather Drive, Vancouver', '2008-07-12', 3, 'Langley Bears', 60500),
(70, 'Jordan Barber', '1963-08-24', 156, 89, 8778625488, 'jordan.barber@soccer.com', '760 Daisy Way, Vancouver', '2001-10-27', 4, 'Langley Bears', 795000),
(71, 'Phil Robins', '1998-05-29', 197, 190, 6049980077, 'phil.robins@soccer.com', '440 Rogue Way, Vancouver', '2021-07-20', 5, 'Langley Bears', 341000),
(72, 'Esther Swan', '1971-02-28', 147, 146, 7786527078, 'esther.swan@soccer.com', '822 Silver St, Vancouver', '2017-08-05', 6, 'Langley Bears', 980000);


-- Insert injuries
INSERT INTO Injury (injury_type, injury_date, injury_status, person_id) VALUES
('Arm', '2022-04-20', 0, 67),
('ACL', '2023-10-15', 1, 68),
('Leg', '2022-09-21', 0, 69),
('Back', '2021-05-07', 0, 70),
('Head', '2021-10-30', 1, 71),
('Finger', '2022-01-22', 0, 72);
INSERT INTO Game (game_id, home, away, game_date) VALUES
(1, 'Vancouver Vipers', 'Richmond Thunder', '2022-01-28'),
(2, 'Burnaby Warriors', 'Surrey Titans', '2022-02-01'),
(3, 'Coquitlam Sharks', 'Langley Bears', '2022-06-02'),
(4, 'Vancouver Vipers', 'Burnaby Warriors','2022-08-15'),
(5, 'Richmond Thunder', 'Coquitlam Sharks', '2022-10-01'),
(6, 'Surrey Titans', 'Langley Bears', '2022-11-27'),
(7, 'Vancouver Vipers', 'Surrey Titans', '2022-12-18'),
(8, 'Burnaby Warriors', 'Coquitlam Sharks', '2023-02-05'),
(9, 'Richmond Thunder', 'Langley Bears', '2023-02-17'),
(10, 'Vancouver Vipers', 'Coquitlam Sharks', '2023-03-13'),
(11, 'Burnaby Warriors', 'Langley Bears', '2023-05-24'),
(12, 'Richmond Thunder', 'Surrey Titans', '2023-08-16'),
(13, 'Langley Bears', 'Vancouver Vipers', '2023-09-01'),
(14, 'Richmond Thunder', 'Burnaby Warriors', '2023-09-08'),
(15, 'Coquitlam Sharks', 'Surrey Titans', '2023-11-19');

-- Insert sponsor records
INSERT INTO Sponsor (sponsor_name, sponsor_email, money_granted) VALUES
('Coca-Cola', 'sponsor@coca-colacompany.com', 50000),
('Adidas', 'sponsor@adidas.com', 40000),
('Visa', 'sponsor@visa.ca', 60000),
('UBC', 'sponsor@ubc.ca', 2000),
('Hyundai', 'sponsor@hyundaimotorgroup.com', 80000);

-- Insert award records
INSERT INTO Awards (award_id, year, award_name) VALUES
(1, 2023, 'Offensive Player of the Year'),
(2, 2023, 'Defensive Player of the Year'),
(3, 2022, 'Offensive Player of the Year'),
(4, 2022, 'Team of the Year'),
(5, 2023, 'Team of the Year'),
(6, 2021, 'Offensive Player of the Year');

INSERT INTO Statistics (stats_id, person_id, game_id, goals, shots_taken, passes_attempted, turnovers, possession_percent) VALUES
(1, 1, 1, 0, 9, 68, 9, 4.03),
(2, 1, 4, 0, 8, 37, 11, 2.87),
(3, 1, 7, 0, 13, 42, 13, 0.94),
(4, 1, 10, 0, 9, 73, 8, 8.39),
(5, 1, 13, 0, 5, 43, 18, 3.31),
(6, 2, 1, 1, 4, 38, 11, 4.43),
(7, 2, 4, 0, 8, 27, 14, 2.22),
(8, 2, 7, 0, 7, 55, 19, 6.13),
(9, 2, 10, 0, 9, 22, 20, 0.61),
(10, 2, 13, 0, 3, 79, 8, 1.75),
(11, 3, 1, 0, 7, 49, 0, 7.67),
(12, 3, 4, 0, 14, 40, 18, 4.44),
(13, 3, 7, 0, 7, 57, 12, 2.64),
(14, 3, 10, 0, 13, 75, 15, 1.21),
(15, 3, 13, 0, 3, 66, 9, 5.24),
(16, 4, 1, 0, 11, 31, 11, 0.95),
(17, 4, 4, 0, 13, 75, 16, 3.05),
(18, 4, 7, 2, 14, 47, 2, 1.02),
(19, 4, 10, 0, 16, 26, 15, 3.55),
(20, 4, 13, 0, 9, 33, 17, 6.99),
(21, 5, 1, 0, 9, 47, 6, 7.75),
(22, 5, 4, 0, 13, 78, 14, 4.99),
(23, 5, 7, 0, 16, 50, 15, 6.64),
(24, 5, 10, 0, 10, 81, 13, 5.62),
(25, 5, 13, 0, 14, 35, 20, 3.86),
(26, 6, 1, 0, 12, 71, 6, 0.95),
(27, 6, 4, 0, 15, 75, 21, 4.81),
(28, 6, 7, 0, 9, 10, 3, 2.64),
(29, 6, 10, 0, 13, 36, 15, 3.03),
(30, 6, 13, 0, 10, 70, 19, 7.64),
(31, 7, 1, 0, 13, 4, 1, 2.77),
(32, 7, 4, 0, 12, 79, 19, 3.97),
(33, 7, 7, 0, 5, 29, 5, 3.66),
(34, 7, 10, 0, 5, 16, 6, 6.23),
(35, 7, 13, 2, 3, 66, 4, 9.11),
(36, 8, 1, 1, 15, 53, 0, 5.78),
(37, 8, 4, 0, 16, 44, 13, 2.5),
(38, 8, 7, 0, 13, 33, 8, 2.98),
(39, 8, 10, 0, 10, 53, 8, 3.2),
(40, 8, 13, 0, 14, 39, 20, 1.56),
(41, 9, 1, 0, 8, 63, 9, 6.49),
(42, 9, 4, 0, 7, 18, 4, 4.62),
(43, 9, 7, 0, 12, 68, 11, 5.28),
(44, 9, 10, 1, 15, 31, 9, 7.27),
(45, 9, 13, 1, 12, 77, 0, 0.09),
(46, 10, 1, 0, 14, 56, 10, 1.03),
(47, 10, 4, 0, 7, 74, 0, 2.03),
(48, 10, 7, 0, 11, 48, 15, 3.75),
(49, 10, 10, 0, 16, 26, 6, 8.3),
(50, 10, 13, 0, 11, 11, 7, 1.01),
(51, 11, 1, 1, 16, 57, 10, 1.66),
(52, 11, 4, 0, 1, 58, 11, 7.86),
(53, 11, 7, 0, 4, 58, 21, 6.81),
(54, 11, 10, 0, 12, 27, 3, 0.87),
(55, 11, 13, 0, 12, 28, 9, 0.83),
(56, 12, 1, 0, 1, 20, 14, 4.03),
(57, 12, 5, 0, 1, 20, 17, 1.26),
(58, 12, 9, 0, 6, 13, 9, 0.66),
(59, 12, 12, 0, 11, 28, 18, 1.79),
(60, 12, 14, 0, 13, 60, 12, 0.31),
(61, 13, 1, 0, 6, 22, 10, 4.43),
(62, 13, 5, 1, 5, 52, 9, 3.44),
(63, 13, 9, 0, 6, 66, 14, 3.41),
(64, 13, 12, 0, 13, 64, 5, 7.83),
(65, 13, 14, 0, 9, 34, 11, 9.85),
(66, 14, 1, 0, 2, 77, 14, 7.67),
(67, 14, 5, 0, 4, 45, 10, 1.6),
(68, 14, 9, 0, 11, 11, 2, 7.77),
(69, 14, 12, 0, 10, 35, 17, 0.09),
(70, 14, 14, 2, 10, 39, 10, 0.1),
(71, 15, 1, 2, 13, 59, 1, 0.95),
(72, 15, 5, 0, 11, 80, 5, 4.7),
(73, 15, 9, 0, 3, 38, 6, 7.39),
(74, 15, 12, 0, 7, 31, 0, 9.06),
(75, 15, 14, 0, 6, 58, 5, 5.03),
(76, 16, 1, 0, 4, 48, 11, 7.75),
(77, 16, 5, 0, 2, 19, 12, 0.03),
(78, 16, 9, 0, 6, 17, 5, 0.06),
(79, 16, 12, 0, 10, 42, 14, 4.38),
(80, 16, 14, 0, 1, 44, 1, 1.09),
   (81, 17, 2, 0, 14, 25, 12, 6.11),
(82, 17, 6, 0, 6, 45, 18, 2.33),
(83, 17, 8, 0, 9, 22, 11, 1.77),
(84, 17, 11, 0, 10, 60, 7, 3.44),
(85, 17, 15, 0, 12, 18, 9, 2.55),
(86, 18, 2, 0, 5, 33, 16, 4.01),
(87, 18, 6, 1, 14, 41, 10, 3.99),
(88, 18, 8, 0, 12, 53, 7, 5.66),
(89, 18, 11, 0, 8, 35, 12, 1.22),
(90, 18, 15, 0, 11, 61, 18, 6.77),
(91, 19, 2, 0, 9, 44, 8, 0.87),
(92, 19, 6, 0, 3, 28, 14, 3.33),
(93, 19, 8, 0, 7, 56, 20, 2.11),
(94, 19, 11, 0, 12, 72, 15, 1.95),
(95, 19, 15, 2, 13, 38, 12, 3.88),
(96, 20, 2, 0, 10, 51, 7, 2.11),
(97, 20, 6, 0, 14, 33, 16, 0.99),
(98, 20, 8, 0, 11, 29, 19, 4.77),
(99, 20, 11, 0, 6, 48, 3, 0.55),
(100, 20, 15, 0, 9, 22, 20, 7.77),
(101, 21, 3, 0, 8, 39, 11, 1.22),
(102, 21, 5, 0, 5, 44, 13, 3.11),
(103, 21, 9, 1, 13, 53, 9, 0.88),
(104, 21, 12, 0, 7, 27, 14, 4.44),
(105, 21, 14, 0, 6, 31, 8, 2.55),
(106, 22, 3, 0, 12, 46, 7, 5.77),
(107, 22, 5, 0, 11, 32, 12, 3.33),
(108, 22, 9, 0, 10, 50, 20, 1.88),
(109, 22, 12, 0, 14, 42, 15, 0.99),
(110, 22, 14, 0, 9, 30, 18, 2.11),
(111, 23, 3, 0, 7, 38, 10, 0.33),
(112, 23, 5, 2, 12, 41, 6, 4.44),
(113, 23, 9, 0, 9, 35, 13, 2.22),
(114, 23, 12, 0, 10, 48, 9, 1.11),
(115, 23, 14, 0, 11, 54, 7, 3.66),
(116, 24, 3, 0, 13, 60, 11, 5.55),
(117, 24, 5, 0, 14, 49, 15, 1.44),
(118, 24, 9, 0, 12, 50, 19, 3.22),
(119, 24, 12, 0, 11, 33, 18, 0.88),
(120, 24, 14, 0, 8, 37, 10, 1.77),
(121, 25, 1, 0, 11, 48, 12, 2.55),
(122, 25, 4, 0, 14, 56, 15, 3.44),
(123, 25, 7, 1, 10, 62, 9, 1.33),
(124, 25, 10, 0, 12, 43, 6, 4.44),
(125, 25, 13, 0, 13, 35, 18, 0.77),
(126, 26, 1, 0, 7, 31, 8, 0.88),
(127, 26, 4, 0, 9, 36, 12, 2.44),
(128, 26, 7, 0, 12, 53, 16, 1.11),
(129, 26, 10, 0, 13, 62, 10, 3.55),
(130, 26, 13, 0, 10, 49, 15, 2.33),
(131, 27, 2, 0, 11, 50, 14, 4.77),
(132, 27, 6, 0, 9, 40, 16, 3.33),
(133, 27, 8, 0, 14, 48, 7, 2.22),
(134, 27, 11, 0, 6, 33, 11, 0.77),
(135, 27, 15, 0, 12, 60, 12, 1.88),
(136, 28, 2, 0, 10, 47, 13, 2.11),
(137, 28, 6, 0, 8, 36, 12, 3.22),
(138, 28, 8, 0, 11, 42, 8, 1.77),
(139, 28, 11, 0, 9, 51, 16, 0.55),
(140, 28, 15, 0, 13, 48, 14, 0.99),
(141, 29, 3, 0, 12, 40, 10, 3.33),
(142, 29, 5, 0, 10, 35, 12, 1.11),
(143, 29, 9, 0, 14, 42, 15, 2.22),
(144, 29, 12, 0, 11, 50, 17, 0.88),
(145, 29, 14, 0, 9, 36, 8, 1.44),
(146, 30, 3, 0, 7, 33, 9, 0.77),
(147, 30, 5, 0, 12, 44, 11, 2.11),
(148, 30, 9, 0, 10, 48, 10, 1.33),
(149, 30, 12, 0, 11, 37, 14, 3.44),
(150, 30, 14, 0, 13, 41, 13, 0.99),
    (151, 31, 1, 0, 9, 38, 12, 2.22),
(152, 31, 4, 0, 11, 45, 15, 1.77),
(153, 31, 7, 0, 10, 50, 14, 3.33),
(154, 31, 10, 0, 12, 42, 11, 0.88),
(155, 31, 13, 0, 8, 36, 10, 1.11),
(156, 32, 1, 0, 14, 55, 16, 4.44),
(157, 32, 4, 0, 12, 48, 12, 3.22),
(158, 32, 7, 0, 9, 37, 14, 2.11),
(159, 32, 10, 0, 11, 50, 15, 1.33),
(160, 32, 13, 0, 10, 44, 13, 0.77),
(161, 33, 2, 0, 8, 36, 11, 1.55),
(162, 33, 6, 0, 14, 42, 18, 3.44),
(163, 33, 8, 0, 12, 39, 15, 2.22),
(164, 33, 11, 0, 10, 48, 12, 0.88),
(165, 33, 15, 0, 9, 33, 10, 1.11),
(166, 34, 2, 0, 13, 55, 17, 4.44),
(167, 34, 6, 0, 10, 49, 15, 2.33),
(168, 34, 8, 0, 11, 42, 12, 3.11),
(169, 34, 11, 0, 12, 36, 14, 1.77),
(170, 34, 15, 0, 14, 40, 13, 2.55),
(171, 35, 3, 0, 9, 38, 11, 1.22),
(172, 35, 5, 0, 12, 44, 14, 0.88),
(173, 35, 9, 0, 11, 50, 15, 2.33),
(174, 35, 12, 0, 10, 42, 12, 1.11),
(175, 35, 14, 0, 8, 36, 10, 0.77),
(176, 36, 3, 0, 14, 55, 16, 3.44),
(177, 36, 5, 0, 12, 48, 13, 2.22),
(178, 36, 9, 0, 9, 37, 11, 1.33),
(179, 36, 12, 0, 11, 50, 15, 0.99),
(180, 36, 14, 0, 10, 44, 12, 1.11),
(181, 37, 1, 0, 8, 36, 10, 0.77),
(182, 37, 4, 0, 12, 42, 14, 1.44),
(183, 37, 7, 0, 10, 38, 12, 2.11),
(184, 37, 10, 0, 11, 50, 13, 3.33),
(185, 37, 13, 0, 9, 36, 11, 0.88),
(186, 38, 1, 0, 14, 55, 15, 4.44),
(187, 38, 4, 0, 12, 48, 13, 3.22),
(188, 38, 7, 0, 9, 37, 12, 1.77),
(189, 38, 10, 0, 11, 50, 14, 2.33),
(190, 38, 13, 0, 10, 44, 11, 0.99),
(191, 39, 2, 0, 8, 36, 12, 1.11),
(192, 39, 6, 0, 14, 42, 15, 3.44),
(193, 39, 8, 0, 12, 39, 13, 2.22),
(194, 39, 11, 0, 10, 48, 11, 1.33),
(195, 39, 15, 0, 9, 33, 10, 0.77),
(196, 40, 2, 0, 13, 55, 16, 4.44),
(197, 40, 6, 0, 10, 49, 14, 2.33),
(198, 40, 8, 0, 11, 42, 12, 3.11),
(199, 40, 11, 0, 12, 36, 13, 1.77),
(200, 40, 15, 0, 14, 40, 15, 2.55),

    (201, 41, 2, 0, 10, 31, 8, 3.22),
(202, 41, 6, 0, 12, 45, 11, 1.88),
(203, 41, 7, 0, 9, 37, 10, 2.11),
(204, 41, 12, 0, 11, 50, 12, 2.44),
(205, 41, 15, 0, 8, 36, 9, 1.77),
(206, 42, 2, 0, 14, 55, 13, 3.33),
(207, 42, 6, 0, 12, 48, 12, 2.11),
(208, 42, 7, 0, 10, 38, 11, 1.44),
(209, 42, 12, 0, 11, 50, 14, 2.22),
(210, 42, 15, 0, 10, 44, 13, 1.77),
(211, 43, 2, 0, 8, 36, 10, 1.33),
(212, 43, 6, 0, 14, 42, 15, 2.88),
(213, 43, 7, 0, 12, 39, 13, 2.11),
(214, 43, 12, 0, 10, 48, 11, 0.99),
(215, 43, 15, 0, 9, 33, 10, 0.77),
(216, 44, 2, 0, 13, 55, 16, 4.44),
(217, 44, 6, 0, 10, 49, 14, 2.33),
(218, 44, 7, 0, 11, 42, 12, 3.11),
(219, 44, 12, 0, 12, 36, 13, 1.77),
(220, 44, 15, 0, 14, 40, 15, 2.55),
(221, 45, 3, 0, 9, 38, 11, 1.22),
(222, 45, 5, 0, 12, 44, 14, 0.88),
(223, 45, 8, 0, 11, 50, 15, 2.33),
(224, 45, 10, 0, 10, 42, 12, 1.11),
(225, 45, 15, 0, 8, 36, 10, 0.77),
(226, 46, 3, 0, 14, 55, 16, 3.44),
(227, 46, 5, 0, 12, 48, 13, 2.22),
(228, 46, 8, 0, 9, 37, 11, 1.33),
(229, 46, 10, 0, 11, 50, 15, 0.99),
(230, 46, 15, 0, 10, 44, 12, 1.11),
(231, 47, 3, 0, 8, 36, 10, 0.77),
(232, 47, 5, 0, 12, 42, 14, 1.44),
(233, 47, 8, 0, 10, 38, 12, 2.11),
(234, 47, 10, 0, 11, 50, 13, 3.33),
(235, 47, 15, 0, 9, 36, 11, 0.88),
(236, 48, 3, 0, 14, 55, 15, 3.33),
(237, 48, 5, 0, 12, 48, 12, 2.11),
(238, 48, 8, 0, 11, 42, 12, 3.22),
(239, 48, 10, 0, 12, 36, 13, 1.77),
(240, 48, 15, 0, 14, 40, 15, 2.55),
(241, 49, 3, 0, 9, 38, 11, 1.22),
(242, 49, 5, 0, 12, 44, 14, 0.88),
(243, 49, 8, 0, 11, 50, 15, 2.33),
(244, 49, 10, 0, 10, 42, 12, 1.11),
(245, 49, 15, 0, 8, 36, 10, 0.77),
(246, 50, 3, 0, 14, 55, 16, 4.44),
(247, 50, 5, 0, 12, 48, 13, 2.33),
(248, 50, 8, 0, 11, 42, 12, 3.11),
(249, 50, 10, 0, 12, 36, 13, 1.77),
(250, 50, 15, 0, 14, 40, 15, 2.55);


INSERT INTO Referee (person_id, name, birthdate, height, weight, phone_number, email, address, date_started, certification_level) VALUES
(1, 'Liam Taylor', '1991-03-18', 175, 69, 2361234567, 'liam.taylor@soccer.com', '567 Oak St, Vancouver', '2009-08-14', 1),
(2, 'Ella Smith', '1996-08-22', 163, 61, 2362345678, 'ella.smith@soccer.com', '345 Elm St, Vancouver', '2017-05-25', 2),
(3, 'Noah Johnson', '1989-12-05', 188, 87, 2363456789, 'noah.johnson@soccer.com', '678 Birch St, Vancouver', '2006-11-30', 3),
(4, 'Mia Davis', '1993-04-30', 168, 68, 2364567890, 'mia.davis@soccer.com', '456 Cedar St, Vancouver', '2014-09-07', 4),
(5, 'Oliver Anderson', '1980-06-14', 178, 81, 2365678901, 'oliver.anderson@soccer.com', '890 Pine St, Vancouver', '2000-04-18', 5);

INSERT INTO Coach (person_id, name, birthdate, height, weight, phone_number, email, address, date_started, current_team, specialization) VALUES
(1, 'Daniel Lee', '1985-04-15', 178, 80, 6048234567, 'daniel.lee@soccer.com', '567 Birch St, Vancouver', '2000-07-10', 'Vancouver Vipers', 'Head Coach'),
(2, 'Olivia Johnson', '1992-09-25', 168, 64, 7788345678, 'olivia.johnson@soccer.com', '890 Elm St, Vancouver', '2010-03-18', 'Vancouver Vipers', 'Assistant Coach'),
(3, 'William Smith', '1988-11-03', 182, 84, 6048456789, 'william.smith@soccer.com', '123 Cedar St, Vancouver', '2005-12-05', 'Richmond Thunder', 'Head Coach'),
(4, 'Sophia Brown', '1995-07-19', 170, 68, 7788567890, 'sophia.brown@soccer.com', '456 Fir St, Vancouver', '2018-02-14', 'Richmond Thunder', 'Assistant Coach'),
(5, 'James Anderson', '1982-03-12', 188, 88, 6048678901, 'james.anderson@soccer.com', '789 Pine St, Vancouver', '2002-09-22', 'Burnaby Warriors', 'Head Coach'),
(6, 'Simon Roach', '1998-05-29', 175, 64, 6045889120, 'simon.roach@soccer.com', '932 Red Oak St, Vancouver', '2015-06-30', 'Burnaby Warriors', 'Assistant Coach'),
(7, 'Madeline Bills', '1987-08-14', 168, 58, 7781029391, 'madeline.bills@soccer.com', '402 Ocean View Rd, Vancouver', '2004-04-03', 'Surrey Titans', 'Head Coach'),
(8, 'Rachel Chu', '1990-01-02', 170, 51, 7789203019, 'rachel.chu@soccer.com', '102 Panther Lane, Vancouver', '2009-11-12', 'Surrey Titans', 'Assistant Coach'),
(9, 'Oscar Rodriguez', '1986-12-08', 206, 101, 7780192939, 'oscar.rodriguez@soccer.com', '882 Parker Drive, Vancouver', '2007-07-27', 'Coquitlam Sharks', 'Head Coach'),
(10, 'Natalie Nguyen', '1994-04-23', 185, 81, 6047789102, 'natalie.nguyen@soccer.com', '721 Red Roof Way, Vancouver', '2013-01-19', 'Coquitlam Sharks', 'Assistant Coach'),
(11, 'Robert Barns', '1983-06-17', 178, 102, 6042102939, 'robert.barns@soccer.com', '900 Frankfurt Rd, Vancouver', '2001-10-09', 'Langley Bears', 'Head Coach'),
(12, 'Bill Bacon', '1997-10-30', 150, 71, 7781920392, 'bill.bacon@soccer.com', '562 Fox Den Lane, Vancouver', '2014-08-07', 'Langley Bears', 'Assistant Coach');


INSERT INTO GivenBy (sponsor_name, award_id) VALUES
('Adidas', 1),
('Coca-Cola', 2),
('Visa', 3),
('Adidas', 4),
('UBC', 5);


INSERT INTO HasSponsor (team_name, sponsor_name) VALUES
('Vancouver Vipers', 'Adidas'),
('Richmond Thunder', 'Coca-Cola'),
('Burnaby Warriors', 'Visa'),
('Surrey Titans', 'Adidas'),
('Coquitlam Sharks', 'UBC');


INSERT INTO LocatedIn (game_id, venue_address) VALUES
(1, '5123 Main Street, Vancouver'),
(2, '5789 Elm Road, Burnaby'),
(3, '5234 Pine Street, Coquitlam'),
(4, '5123 Main Street, Vancouver'),
(5, '5456 Oak Avenue, Richmond'),
(6, '5101 Maple Lane, Surrey'),
(7, '5123 Main Street, Vancouver'),
(8, '5789 Elm Road, Burnaby'),
(9, '5456 Oak Avenue, Richmond'),
(10, '5123 Main Street, Vancouver'),
(11, '5789 Elm Road, Burnaby'),
(12, '5456 Oak Avenue, Richmond'),
(13, '1923 River Road, Langley'),
(14, '5456 Oak Avenue, Richmond'),
(15, '5234 Pine Street, Coquitlam');

INSERT INTO ParticipatesIn (game_id, team_1, team_2) VALUES
(1, 'Vancouver Vipers', 'Richmond Thunder'),
(2, 'Burnaby Warriors', 'Surrey Titans'),
(3, 'Coquitlam Sharks', 'Langley Bears'),
(4, 'Vancouver Vipers', 'Burnaby Warriors'),
(5, 'Richmond Thunder', 'Coquitlam Sharks'),
(6, 'Surrey Titans', 'Langley Bears'),
(7, 'Vancouver Vipers', 'Surrey Titans'),
(8, 'Burnaby Warriors', 'Coquitlam Sharks'),
(9, 'Richmond Thunder', 'Langley Bears'),
(10, 'Vancouver Vipers', 'Coquitlam Sharks'),
(11, 'Burnaby Warriors', 'Langley Bears'),
(12, 'Richmond Thunder', 'Surrey Titans'),
(13, 'Langley Bears', 'Vancouver Vipers'),
(14, 'Richmond Thunder', 'Burnaby Warriors'),
(15, 'Coquitlam Sharks', 'Surrey Titans');

INSERT INTO WinsAward (award_id, person_id, team_name) VALUES
(1, 2, NULL),
(2, 32, NULL),
(3, 25, NULL),
(4, NULL, 'Coquitlam Sharks'),
(5, NULL, 'Surrey Titans'),
(6, 2, NULL);




INSERT IGNORE INTO Referees (person_id, game_id) VALUES
-- Ref 1
(1, 1),(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 7),(1, 8),(1, 9),(1, 10),(1, 11),(1, 12),(1, 13),(1, 14),(1, 15),
-- Ref 2
(2, 1),(2, 3),(2, 8),(2, 15),
-- Ref 3
(3, 4),(3, 5),(3, 11),(3, 15),
-- Ref 4
(4, 1),(4, 2),(4, 3),(4, 4),(4, 5),(4, 6),(4, 7),(4, 8),(4, 9),(4, 10),(4, 11),(4, 12),(4, 13),(4, 14),(4, 15),
-- Ref 5
(5, 2),(5, 7),(5, 12),(5, 14);

-- Local demo accounts use plain-text passwords; do not use this pattern in production.
INSERT INTO users (user_id, name, email, password, role) VALUES
(1, 'Demo Admin', 'admin@football.local', 'admin123', 'admin'),
(2, 'Demo Fan', 'fan@football.local', 'user123', 'user');

INSERT INTO UserFan (user_id, name, email, password, favorite_team) VALUES
(2, 'Demo Fan', 'fan@football.local', 'user123', 'Vancouver Vipers');

INSERT INTO Orders (order_id, user_id, order_date, total_amount, payment_status, order_status, paid_at, confirmed_at) VALUES
(1, 2, '2026-09-01 12:00:00', 120.00, 'pending', 'pending', NULL, NULL),
(2, 2, '2026-09-02 14:30:00', 95.00, 'paid', 'pending', '2026-09-02 14:32:00', NULL),
(3, 2, '2026-09-03 10:00:00', 65.50, 'paid', 'confirmed', '2026-09-03 10:05:00', '2026-09-03 11:00:00');

INSERT INTO OrderItems (order_id, item_name, quantity, unit_price) VALUES
(1, 'Home team jersey', 1, 80.00),
(1, 'Club scarf', 1, 40.00),
(2, 'Match ticket', 1, 65.00),
(2, 'Club cap', 1, 30.00),
(3, 'Match ticket', 1, 65.50);

INSERT INTO Tickets (game_id, seat_number, price, status) VALUES
(1, 'A-12', 65.00, 'available'),
(2, 'B-08', 55.00, 'available'),
(3, 'C-21', 45.00, 'reserved');

INSERT INTO Merchandise (name, description, price, stock) VALUES
('Home team jersey', 'Official home colors jersey', 80.00, 25),
('Club scarf', 'Supporters scarf in club colors', 40.00, 50),
('Club cap', 'Embroidered club cap', 30.00, 35);

INSERT INTO News (title, content, published_at) VALUES
('Season fixtures announced', 'The club schedule is now available for supporters.', '2026-09-01 09:00:00'),
('Youth academy registration open', 'Registration is open for the upcoming youth academy program.', '2026-09-05 10:00:00'),
('Matchday ticket information', 'Ticket availability and venue details are listed in the match schedule.', '2026-09-10 11:00:00');
