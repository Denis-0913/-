-- ������� �����
CREATE SCHEMA dim; CREATE SCHEMA fact;

/* ������� Fact_Flights - �������� ����������� ��������. 
 * ���� � ������ ������ ��� ������� ������� � ����������� - ������ ������� ��������� ����������*/
CREATE TABLE fact.fact_flights (
	flight_no bpchar(6) NOT NULL, -- � ������� �� ������� ���� � ������� �����, �� ������������ ������ ����� (flight_no) � ���� ����������� (scheduled_departure ��� actual_departure) 
	--�������� ������������ ������, ������� ���������� ������� ���� �������� ������ ��������� ������������ � �������� ������
	passenger_id text references dim.dim_passengers(passenger_id), -- �������� (bookings.tickets.passenger_name)
	actual_departure timestamptz NOT NULL, -- ���� � ����� ������ (����) (bookings.flights.actual_departure)
	actual_arrival timestamptz NOT NULL, -- ���� � ����� ������� (����) (bookings.flights.actual_arrival)
	delay_time_departure int4 NOT NULL, -- �������� ������ (������� ����� ����������� � ��������������� ����� � ��������) (actual_departure - scheduled_departure)
	delay_time_arrival int4 NOT NULL, -- �������� ������� (������� ����� ����������� � ��������������� ����� � ��������) (actual_arrival - scheduled_arrival)
	aircraft_code varchar(30) NOT NULL REFERENCES dim.dim_aircrafts(aircraft_code), -- ��� �������� (bookings.flights.aircraft_code)
	airports_departure_code varchar(30) NOT NULL REFERENCES dim.dim_airports(airport_code), -- �������� ������ (bookings.flights.airports_departure)
	airports_arrival_code varchar(30) NOT NULL REFERENCES dim.dim_airports(airport_code),  -- �������� ������� (bookings.flights.airports_arrival)
	fare_conditions_id int REFERENCES dim.dim_tariff(fare_conditions_id), -- ���� ������ ������������ (dim.dim_tariff)
	amount numeric(10,2) -- ��������� (bookings.ticket_flights.amount)
);



-- ������� ���������� ��������� dim_aircrafts
CREATE TABLE dim.dim_aircrafts (
	aircraft_code bpchar(3) PRIMARY KEY, -- ���� (bookings.aircrafts.aircraft_code)
	model varchar(20) NOT NULL, -- ������ (bookings.aircrafts.model)
	manufacturer varchar(20) NOT NULL, -- ������������� - ������ ����� � ��������  ������ �������� 
	"range" int4 NOT NULL -- ���������� (bookings.aircrafts."range")
);

-- ������� ���������� ���������� dim_airports
CREATE TABLE dim.dim_airports (
	airport_code bpchar(3) PRIMARY KEY, -- ���� (bookings.airports.airport_code)
	airport_name varchar(50) NOT NULL, -- �������� ��������� (bookings.airports.airport_name)
	airport_city varchar(50) NOT NULL, -- ����� ��������� (bookings.airports.city)
	longitude float(8) NOT NULL, -- ������� ������ (bookings.airports.longitude)
	latitude float(8) NOT NULL -- ������ ������ (bookings.airports.latitude)
);

-- ������� ���������� ���������� dim_passengers
CREATE TABLE dim.dim_passengers (
	passenger_id varchar(20) PRIMARY KEY, -- ���� �������� (bookings.tickets.passenger_id)
	passenger_name text NOT NULL, -- ��� �������� (bookings.tickets.passenger)
	phone  varchar(20), -- �������  ��������� (bookings.tickets.contact_data ->> 'phone')
	email  varchar(150) -- email  ��������� (bookings.tickets.contact_data ->> 'email')
);

-- ������� ���������� ������� dim_tariff
CREATE TABLE dim.dim_tariff (
	fare_conditions_id serial PRIMARY KEY, -- ���� ������ - �� �����, ������ ����
	fare_conditions varchar(10) NOT NULL -- ����� (bookings.seats.fare_conditions)
);

-- ������� ���������� ��� dim_calendar
CREATE TABLE dim.dim_calendar (
	id serial PRIMARY KEY, -- ����
	"date" date UNIQUE NOT NULL , -- ����
	YEAR int4 NOT NULL, -- ���
	n_week int4 NOT NULL, -- ������
	day_week varchar(10) NOT NULL-- ���� ������
);

-- ��������� ���������� ��� dim_calendar �������� SQL
INSERT INTO dim.dim_calendar("date",YEAR,n_week, day_week)
SELECT gs, date_part('year', gs), date_part('week', gs), to_char(gs, 'day')
FROM generate_series('2016-09-13', current_date, interval '1 day') as gs; 
-- 2016-09-13 - ��� ���� � ������� �������. ����� ������ �� ������� ������, ��� ��� ���� ���� ����� ����� �� �������. ���� ���� ����� ������� �� ��� ������, ���� ������ ����� �����������.

