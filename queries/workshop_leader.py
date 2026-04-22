"""Queries for the workshop leader functionality"""

from . import db_connect


def workshop_get(email, year):
    with db_connect() as con:
        with con.cursor() as cur:
            cur.execute(
                """SELECT title, advertisement, description,
                        capacity, computer_needs, room_needs,
                        max_repeat, parent_questions, other_information
                   FROM workshop w
                   join person_workshop pw
                   ON w.id = pw.workshop_id
                   WHERE pw.person_email = %s
                   AND pw.role = 'Lead'
                   AND w.event_year = %s""", [email,year])
            return cur.fetchone()

def workshop_update(email, year, values):
    with db_connect() as con:
        with con.cursor() as cur:
            cur.execute(
                """SELECT w.id
                   FROM workshop w
                   join person_workshop pw
                   ON w.id = pw.workshop_id
                   WHERE pw.person_email = %s
                   AND pw.role = "Lead"
                   AND w.event_year = %s""", [email,year])
            id =  cur.fetchone()[0]
            values.append(id)
            print("ID", id)
            cur.execute(
                """UPDATE workshop
                    SET title = %s,
                    advertisement = %s,
                    description = %s,
                    capacity = %s,
                    computer_needs = %s,
                    room_needs = %s,
                    max_repeat = %s,
                    parent_questions = %s,
                    other_information = %s
                   WHERE id = %s
                   """, values)
            con.commit()
            return id


if __name__ == "__main__":
    print("==== workshop ====")
    print(workshop_get('petersva@jmu.edu', '2024'))
