---
part: records
---
# Records and the pass rule

| Record | Written by | Holds |
|---|---|---|
| BasicsLesson | PianoCore, by hand | the number, the title, the text and the exercises |
| BasicsExercise | PianoCore, by hand | the id ("lesson.exercise", such as "2.1"), title, instruction, notes, hands, hint, timed or not, and the tempo |
| Hint | PianoCore | name and key, name only, or staff only |
| BasicsProgress | PianoCore | the ids of the passed exercises |
| Saved progress | The app | BasicsProgress as JSON, in the user defaults under "basics.progress" |
| Staff step | PianoCore | where a white key sits: 0 is the bottom line, 8 the top line |

## The lessons

| Lesson | Teaches | Exercises | Hint | Timed |
|---|---|---|---|---|
| 1 Find middle C | groups of two and three black keys; each C; middle C | 1.1 the groups of two, 1.2 every C from C1 to C8, 1.3 middle C | name and key | no |
| 2 Right hand in C position | finger numbers; thumb on C4 | 2.1 up five keys, 2.2 up and down, 2.3 skips C E G | name and key | no |
| 3 Left hand in C position | little finger on C3, thumb on G3 | 3.1 up, 3.2 down and up, 3.3 skips | name and key | no |
| 4 Note names | A to G; D between two black keys; F left of three | 4.1 names in C position, 4.2 every D, 4.3 F and G | name only | no |
| 5 Beats | quarter, half and whole notes | 5.1 "Hot Cross Buns", 5.2 "Mary Had a Little Lamb" | name and key | yes |
| 6 Read notes on the staff | the treble staff; E4 bottom line; middle C on a ledger line | 6.1 read and play, 6.2 "Ode to Joy", first line | staff only | no |
| 7 Your first tune with both hands | left hand plays one note a bar | 7.1 left hand alone, 7.2 both hands, "Mary Had a Little Lamb" | name and key | yes |

## The pass rule

1. The score comes from wait mode of D4: right notes, wrong keys and late
   notes.
2. An exercise passes when 90 percent or more of its notes are right.
3. A timed exercise also needs 10 percent or fewer of its notes late.
4. A score with no notes never passes.
5. A pass is kept. A later try that does not pass does not take it away.

## The gate

Lesson 1 is open. Lesson n opens when each exercise of lesson n minus 1 is
passed.

## The staff

| Clef | Bottom line | Example |
|---|---|---|
| Treble | E4, step 0 | G4 is step 2. Middle C is step -2, on one ledger line |
| Bass | G2, step 0 | C3 is step 3. Middle C is step 10, on one ledger line |

A ledger line sits on each even step below -1 or above 9, up to the note.
