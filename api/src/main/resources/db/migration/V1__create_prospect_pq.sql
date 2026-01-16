create table if not exists prospect_pq (
  id uuid primary key,
  prospect_id varchar(128) not null unique,
  first_name varchar(100) not null,
  last_name varchar(100) not null,
  dob date not null,
  ssn_ciphertext text not null,
  ssn_last4 char(4) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
