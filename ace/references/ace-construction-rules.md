# ACE 6.7 Construction Rules

**Source:** [ACE 6.7 Construction Rules](https://attempto.ifi.uzh.ch/site/docs/ace_constructionrules.html)
**Purpose:** This document defines the construction rules for ACE 6.7, specifying the admissible sentence structures and vocabulary.
**Notation:** Sentences prefixed with `*` are NOT part of ACE and serve as counter-examples.

---

## 1. Words

### 1.1 Function Words (Predefined)

Function words are predefined and cannot be changed by users. Categories include:

- **Determiners:** a, the, some, all, no, every, each
- **Quantifiers:** numeric determiners (1, 2, 3, etc.)
- **Coordinators:** and, or
- **Negation words:** not, no
- **Pronouns:** he, she, it, they, him, her, them, himself, herself, itself, themselves, someone, somebody, something, who, what, which
- **Query words:** who, what, which, whose, where, when, how
- **Modal auxiliaries:** can, must, should, may
- **Copula:** be (is, are, was, were)
- **Saxon genitive marker:** 's

### 1.2 Fixed Phrases (Predefined)

Examples of fixed phrases:

- `there is ...`
- `it is not possible that ...`
- `it is false that ...`
- `it is not provable that ...`

### 1.3 Content Words (User-Defined)

Content words can be defined by users and include:

- **Nouns:** card, screen, water
- **Verbs:** enter, wait, accept
- **Adjectives:** valid, blue, large
- **Adverbs:** quickly, carefully
- **Prepositions:** in, on, at, to, from

Content words can be:

- **Simple:** `code`
- **Compound (hyphenated):** `check-code`, `automated-teller`

---

## 2. Phrases

### 2.1 Noun Phrases

#### 2.1.1 Singular Countable Common Noun Phrases

```
a card
the card
1 card
one card
no card
every card
each card
not every card
not each card
```

**Syntactic Sugar:**

- `all cards` = `every card`
- `no cards` = `no card`

**Interchangeable Determiners:**

- `a` = `1` = `one`
- `every` = `each`
- `not every` = `not each`

#### 2.1.2 Plural Countable Common Noun Phrases

**Collective:**

```
the cards
some cards
3 cards
three cards
```

**Distributive:**

```
each of the cards
each of some cards
each of 3 cards
each of three cards
```

**Number Representation:**

- Integers up to 12 can be written as words: `twelve cats`
- Larger integers must be digits: `13 cats`

#### 2.1.3 Mass Common Noun Phrases

```
some water
no water
all water
not all water
```

#### 2.1.4 Proper Names

- Can be singular or plural
- Can occur with or without definite determiner `the`
- Multiword proper names must be hyphenated: `United-Nations`

```
John
Mr-Miller
the United-Nations
```

#### 2.1.5 Integer and Real Numbers

**Format Rules:**

- **Integer:** non-empty sequence of digits (0-9)
- **Real:** digits + period + digits (e.g., `3.141`)
- **Positive:** no plus sign prefix
- **Negative:** minus sign prefix

```
0
12
-2
0.0
0.2
2.0
3.141
-2.718
```

#### 2.1.6 Arithmetic Expressions

Arithmetic expressions use operators: `+`, `-`, `*`, `/`, `^`

- Standard operator precedence applies
- Use parentheses to modify precedence
- ACE parser APE does not evaluate expressions

```
1 + 2 / X * 4
(1 + 2) / X * 4
Pi/2
2 ^ 3
2 ^ (3 ^ 4)
(2 ^ 3) ^ 4
```

#### 2.1.7 Strings

- Unicode characters enclosed in double quotes `"..."`
- Escape quotation marks and backslashes with `\`
- Concatenation operator: `&` (left-associative)
- ACE parser APE does not perform concatenations

```
""
"abc"
"ab\"cd"
"ab\\cd"
"abc" & "123"
```

#### 2.1.8 Sets and Lists

**Sets:** unordered collections enclosed in curly brackets `{...}`

```
{}
{1, 2, 3}
{John, Mary}
```

**Lists:** ordered sequences enclosed in square brackets `[...]`

```
[]
[1, 2, 3]
[John, Mary]
```

#### 2.1.9 Variables

Variables start with uppercase letter followed by letters, digits, hyphens or underscores.

```
X
A1
Some-Variable
Some_Variable
```

**Anonymous Variable:** `_` (underscore)

#### 2.1.10 Bracketed Noun Phrases

Group terms using parentheses for function-like notations:

```
f(X)
g(a, b, C)
```

### 2.2 Apposition

Apposition provides additional information about a noun phrase:

```
John who is a customer enters a card.
John, a customer, enters a card.
John the customer enters a card.
```

**Usage:**

- Subject position: all three forms allowed
- Non-subject position: only second form allowed

```
A clerk sees John, a customer.
* A clerk sees John who is a customer.
* A clerk sees John the customer.
```

### 2.3 Adjective Phrases

Adjectives can modify nouns:

**Attributive Position (before noun):**

```
a valid card
a blue and valid card
```

**Predicative Position (after copula):**

```
A card is valid.
A card is blue and valid.
```

**Comparatives and Superlatives:**

```
a larger card
the largest card
```

**Comparison Constructs:**

```
John is as rich as Mary.
John is richer than Mary.
John is less rich than Mary.
```

### 2.4 Adverb Phrases

Adverbs modify verbs:

```
John quickly enters a card.
John enters a card quickly.
```

**Comparatives and Superlatives:**

```
John waits more patiently than Mary.
John waits most patiently.
John waits less patiently than Mary.
John waits least patiently.
```

### 2.5 Prepositional Phrases

Prepositional phrases consist of preposition + noun phrase:

```
in a bank
at a bank
to a bank
from a bank
```

**Usage:**

```
John waits in a bank.
A card in a slot is valid.
```

### 2.6 Verb Phrases

#### 2.6.1 Intransitive Verbs

```
A customer waits.
```

#### 2.6.2 Transitive Verbs

**One Object:**

```
A customer enters a card.
```

**Two Objects:**

```
A clerk gives a card to a customer.
A clerk gives a customer a card.
```

#### 2.6.3 Copula Constructions

**With Adjective:**

```
A card is valid.
A card is not valid.
```

**With Noun Phrase:**

```
John is a customer.
John is not a customer.
```

**With Prepositional Phrase:**

```
John is in a bank.
```

**Existential `there is`:**

```
There is a customer.
There are some customers.
There is no card.
```

#### 2.6.4 Verb Modality

Modal auxiliaries express possibility, necessity, permission:

```
A customer can enter a card.
A customer cannot enter a card.
A customer must enter a card.
A customer must not enter a card.
A customer should enter a card.
A customer should not enter a card.
A customer may enter a card.
A customer may not enter a card.
```

#### 2.6.5 Verb Negation

```
A customer does not enter a card.
```

#### 2.6.6 Negation as Failure

```
A customer does not provably enter a card.
```

#### 2.6.7 Verb Modifiers

Verbs can be modified by:

- Adverbs: `John quickly enters a card.`
- Prepositional phrases: `John enters a card in a bank.`

---

## 3. Anaphoric References

### 3.1 Reflexive Pronouns

```
A customer sees himself.
Customers see themselves.
```

### 3.2 Personal Pronouns

```
A customer enters a card. He waits.
A customer enters a card. She waits.
Customers enter cards. They wait.
```

### 3.3 Possessive Pronouns

```
A customer enters his card.
A customer enters her card.
A customer enters his/her card.
Customers enter their cards.
```

### 3.4 Definite Noun Phrases

```
A customer enters a card. The customer waits.
A customer enters a card. The card is valid.
```

### 3.5 Variables as Anaphora

```
A customer enters a card X. X is valid.
```

---

## 4. Sentences

### 4.1 Declarative Sentences

#### 4.1.1 Simple Sentences

**Structure:** subject + verb phrase

```
A customer waits.
John enters a card.
A card is valid.
```

#### 4.1.2 Composite Sentences

**Coordination (and):**

```
John waits and Mary enters a card.
```

**Coordination (or):**

```
John waits or Mary enters a card.
```

**Multiple Subjects:**

```
John and Mary wait.
John or Mary waits.
```

**Multiple Objects:**

```
John enters a card and a code.
```

**Multiple Verb Phrases:**

```
John enters a card and waits.
```

#### 4.1.3 Conditional Sentences

```
If John enters a card then the automated-teller accepts it.
If John enters a card and he waits then the automated-teller accepts the card or rejects it.
```

#### 4.1.4 Logical Negation

**Negation of Complete Sentences:**

```
It is false that a screen blinks.
It is not true that a screen blinks.
It is false that a screen blinks and that John enters a code.
```

**Backward Compatibility:**

```
It is true that a screen blinks.
```

#### 4.1.5 Negation as Failure

```
It is not provable that a screen blinks.
It is not provable that a screen blinks and that John enters a code.
```

#### 4.1.6 Modality

**Sentence-level Modality:**

```
It is possible that John waits.
It is not possible that John waits.
It is necessary that John waits.
It is not necessary that John waits.
It is recommended that John waits.
It is not recommended that John waits.
It is admissible that John waits.
It is not admissible that John waits.
```

**Coordinated Sentences:**

```
It is not necessary that John enters a card and that he types a code.
It is recommended that the surgeon operates the patient.
It is not admissible that the patient takes his/her own medicine.
```

#### 4.1.7 Sentence Subordination

**General Form:**

```
A clerk believes that a customer inserts a card.
```

**Same Subject (shortened form):**

```
John wants that John inserts a card.
→ John wants to insert a card.
```

**Modifier Placement:**

```
John eagerly in the morning wants to insert a card.
```

**Note:** Adverbs and prepositional phrases must occur before the main verb, not between the verb and `that`/`to`.

### 4.2 Interrogative Sentences

All interrogative sentences must end with `?`.

#### 4.2.1 Yes/No Queries

```
Does John enter a card?
Does John not wait?
Do John and Mary wait in a garden?
Is the card valid?
Is the card not valid?
Is it true that a man waits?
Is it false that a man waits?
```

#### 4.2.2 Wh-Queries

**Query Words:**

- `who`, `whose`, `what`, `which` — ask for subjects/objects
- `how`, `where`, `when` — ask for verb modifiers

```
Who waits?
Who wait? (= Who waits?)
Each of who waits?
Whose dog barks?
A card of who is valid?
Who does John not see?
John does not see who?
Who is John?
John is who?
What does a man not eat?
A man does not eat what?
Which customer enters a card and types a code?
How does John enter a card?
John enters a card how?
Where does John wait?
John waits where?
When does John wait?
John waits when?
There is who?
Who is there?
There is which man?
Which man is there?
Where is John?
John is who?
```

#### 4.2.3 How Much/Many Queries

```
How much water boils?
How many men wait?
How many men have how many apples?
John gives how much food to how many children?
```

### 4.3 Imperative Sentences

**Structure:** addressee + comma + verb phrase + exclamation mark

```
John, go to your own bank!
John and Mary, clean yourselves!
Every dog, do not bark!
John's brother, return the book to Mary!
```

---

## 5. ACE Texts

An ACE text is a sequence of declarative, interrogative and imperative sentences.

**Anaphoric Reference Rules:**

- All sentences can refer anaphorically to preceding **declarative** sentences
- Sentences **cannot** refer to interrogative or imperative sentences

**Example:**

```
Mary enters a card into a machine. Its screen blinks or Mary waits.

A man has a car. Does he see the car? John, identify the car!
```

---

## Summary: Key ACE Constraints

1. **Determinism:** Each sentence has unambiguous structure
2. **Content words:** User-defined (nouns, verbs, adjectives, adverbs, prepositions)
3. **Function words:** Predefined (determiners, pronouns, coordinators, etc.)
4. **Compound words:** Use hyphens (e.g., `check-code`, `United-Nations`)
5. **Numbers:** Write 1-12 as words or digits; 13+ only as digits
6. **Strings:** Unicode in double quotes with escape sequences
7. **Variables:** Start with uppercase, use letters/digits/hyphens/underscores
8. **Anaphora:** Only refer to preceding declarative sentences
9. **Modality:** Can apply to verb phrases or complete sentences
10. **Negation:** Multiple forms (standard negation, negation as failure)
11. **Queries:** Three types (yes/no, wh-queries, how much/many)
12. **Commands:** Must end with exclamation mark

---
