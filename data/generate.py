"""Generate fake data for the database."""

import csv
import faker
import psycopg
import random

YEAR = 2024    # conference year
NUM_FAC = 25   # faculty volunteers
NUM_ORG = 3    # madistem organizers
NUM_STU = 100  # student volunteers
NUM_WORK = 20  # hands-on workshops
NUM_SLOT = 3   # schedule time slots

# Connect to the database
con = psycopg.connect(host="localhost", port="5432", user="profs", dbname="profs")
cur = con.cursor()

# Initialize generators
random.seed(0)
fake = faker.Faker()


def jmu_email(dukes=False):
    """Generate a fake JMU email address."""
    eid = fake.last_name()[:6] + fake.random_letter() + fake.random_letter()
    eid = eid.lower()
    suffix = "@dukes.jmu.edu" if dukes else "@jmu.edu"
    return eid + suffix


def main():

    # Get the department codes
    with open("../data/department.csv", newline="") as file:
        data = csv.reader(file)
        next(data)  # Skip the header row
        dept_codes = [row[0] for row in data]

    # Generate fake faculty
    faculty = []
    for _ in range(NUM_FAC):
        person = (
            jmu_email(),
            "Faculty",
            fake.first_name(),
            fake.last_name(),
            fake.basic_phone_number(),
            random.choice(dept_codes),
        )
        cur.execute("INSERT INTO person VALUES (%s, %s, %s, %s, %s, %s)", person)
        faculty.append(person[0])
    con.commit()
    random.shuffle(faculty)

    # Generate fake students
    students = []
    for _ in range(NUM_STU):
        person = (
            jmu_email(dukes=True),
            "Student",
            fake.first_name(),
            fake.last_name(),
            None,  # no phone number
            random.choice(dept_codes),
        )
        cur.execute("INSERT INTO person VALUES (%s, %s, %s, %s, %s, %s)", person)
        students.append(person[0])
    con.commit()
    random.shuffle(students)

    # Pick random organizers
    for email in faculty[:NUM_ORG]:
        roles = fake.catch_phrase() + ", " + fake.catch_phrase()
        cur.execute("INSERT INTO organizer VALUES (%s, %s, %s)", (YEAR, email, roles))
    con.commit()

    # Get the room names
    with open("../data/room.csv", newline="") as file:
        data = csv.reader(file)
        next(data)  # Skip the header row
        room_names = [row[0] for row in data]
    random.shuffle(room_names)

    # Generate fake workshops (with room assignments)
    for i in range(NUM_WORK):
        workshop = (
            random.choice(["Proposed", "Accepted"]),
            fake.bs().title(),
            fake.paragraph(5),
            YEAR,
            room_names[i],
        )
        cur.execute("INSERT INTO workshop "
                    "(state, title, advertisement, event_year, room_name) "
                    "VALUES (%s, %s, %s, %s, %s)", workshop)
    con.commit()

    # Assign people to workshops
    for i in range(NUM_WORK):
        email = faculty[NUM_ORG + i]
        cur.execute("INSERT INTO person_workshop VALUES (%s, %s, 'Lead')", (email, i+1))
    for i in range(NUM_WORK):
        email = students[2*i]
        cur.execute("INSERT INTO person_workshop VALUES (%s, %s, 'Assist')", (email, i+1))
        email = students[2*i + 1]
        cur.execute("INSERT INTO person_workshop VALUES (%s, %s, 'Assist')", (email, i+1))
    con.commit()

    # Assign workshops to time slots
    for i in range(NUM_WORK):
        beg = random.randint(1, NUM_SLOT)  # 1st time slot
        end = beg + random.randint(0, 1)   # 2nd time slot (some workshops run twice)
        end = min(end, NUM_SLOT)
        for slot in range(beg, end+1):
            cur.execute("INSERT INTO workshop_timeslot VALUES (%s, %s, %s)", (i+1, YEAR, slot))
    con.commit()


if __name__ == "__main__":
    main()
