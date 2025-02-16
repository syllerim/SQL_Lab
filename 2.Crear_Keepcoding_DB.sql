CREATE TABLE person (
  person_id SERIAL PRIMARY KEY,
  full_name VARCHAR(150) NOT NULL,
  fiscal_id VARCHAR(50) NOT NULL UNIQUE,
  telephone VARCHAR(30),
  country VARCHAR(30),
  date_of_birth DATE,
  nationality VARCHAR(50),
  subscribed_to_ads BOOLEAN DEFAULT FALSE,
  date_joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_Auth (
  user_auth_id SERIAL PRIMARY KEY,
  person_id INT NOT NULL UNIQUE REFERENCES person(person_id),
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  date_joined_platform TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP NULL,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE program (
  program_id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255) NOT NULL,
  long_description TEXT,
  program_type VARCHAR(10) CHECK (program_type IN ('bootcamp', 'course')),
  format VARCHAR(10) CHECK (format IN ('online', 'in-person')),
  duration_minutes INT NOT NULL,
  price NUMERIC(10,2),
  level VARCHAR(50),
  is_active BOOLEAN DEFAULT TRUE,
  job_opportunities TEXT
);

CREATE TABLE module (
  module_id SERIAL PRIMARY KEY,
  program_id INT NOT NULL REFERENCES program(program_id),
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255),
  long_description TEXT,
  duration_minutes INT NOT NULL,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  module_order INT NOT NULL
);

CREATE TABLE class (
  class_id SERIAL PRIMARY KEY,
  module_id INT NOT NULL REFERENCES module(module_id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  class_order INT NOT NULL,
  duration_minutes INT NOT NULL,
  scheduled_start_date TIMESTAMP,
  zoom_url TEXT NULL,
  video_url TEXT NULL
);

CREATE TABLE module_instructor (
  module_instructor_id SERIAL PRIMARY KEY,
  module_id INT NOT NULL REFERENCES module(module_id),
  instructor_id INT NOT NULL REFERENCES person(person_id),
  role VARCHAR(30) CHECK (role IN ('instructor', 'director', 'both'))
);

CREATE TABLE assignment (
  assignment_id SERIAL PRIMARY KEY,
  module_id INT NOT NULL REFERENCES module(module_id),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  deadline TIMESTAMP NOT NULL
);

CREATE TABLE enrollment (
  enrollment_id SERIAL PRIMARY KEY,
  person_id INT NOT NULL REFERENCES person(person_id),
  program_id INT NOT NULL REFERENCES program(program_id),
  start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  end_date TIMESTAMP NULL,
  pause_date TIMESTAMP NULL,
  resume_date TIMESTAMP NULL,
  promo_code VARCHAR(10),
  status VARCHAR(20) CHECK (status IN ('registered', 'in-progress', 'paused', 'completed')) DEFAULT 'registered'
);

CREATE TABLE progress (
  progress_id SERIAL PRIMARY KEY,
  person_id INT NOT NULL REFERENCES person(person_id),
  class_id INT NOT NULL REFERENCES class(class_id),
  watched BOOLEAN DEFAULT FALSE,
  watched_date TIMESTAMP NULL
);

CREATE TABLE student_assignment (
  student_assignment_id SERIAL PRIMARY KEY,
  person_id INT NOT NULL REFERENCES person(person_id),
  assignment_id INT NOT NULL REFERENCES assignment(assignment_id),
  submitted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  github_url TEXT NOT NULL,
  grade VARCHAR(20),
  feedback TEXT NULL
);

CREATE TABLE payment_plan (
  plan_id SERIAL PRIMARY KEY,
  enrollment_id INT NOT NULL REFERENCES enrollment(enrollment_id),
  total_amount NUMERIC(10,2) NOT NULL,
  number_installments INT NOT NULL,
  amount_installments NUMERIC(10,2) NOT NULL
);

CREATE TABLE payment (
  payment_id SERIAL PRIMARY KEY,
  plan_id INT NOT NULL REFERENCES payment_plan(plan_id),
  amount NUMERIC(10,2) NOT NULL,
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  installment_number INT DEFAULT 1,
  status VARCHAR(20) CHECK (status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending'
);