-- Adds client_id to streams and events

ALTER TABLE streams ADD client_id STRING;

ALTER TABLE events ADD client_id STRING;
