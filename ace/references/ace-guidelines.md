# ACE 6.7 - Guidelines

**Source**: [ACE 6.7 Guidelines](https://attempto.ifi.uzh.ch/site/docs/ace_nutshell.html)
**Purpose**: ACE is a controlled natural language that can be unambiguously parsed into formal logic. This guide covers vocabulary, syntax, ambiguity handling and anaphoric references.

---

## 1. VOCABULARY

### Predefined Components

- **Function words**: determiners, conjunctions, query words
- **Fixed phrases**: "there is", "it is false that"
- **Content words**: nouns, proper names, verbs, adjectives, adverbs

### Lexicon Management

- APE (Attempto Parsing Engine) includes a basic lexicon
- Users can import custom lexicons (user-defined words take precedence)
- Unknown words can be prefixed by word-class:
    - `n:kitkat` (noun)
    - `p:Thomas` (proper name)
    - `v:google` (verb)
    - `a:trusted` (adjective)
    - `a:undeviatingly` (adverb)

---

## 2. GRAMMAR AND SYNTAX

### Text Structure

An ACE text = sequence of anaphorically interrelated sentences (declarative, interrogative, imperative)

---

### 2.1 SIMPLE SENTENCES

**Structure**: `subject + verb + complements + adjuncts`

**Requirements**:

- Minimum: subject + verb
- Complements: required for transitive/ditransitive verbs
- Adjuncts: optional (adverbs, prepositional phrases)

**Examples**:

```
A customer waits.
The temperature is -2°C.
A customer owns a card.
A customer gives a card to a clerk.
```

---

### 2.2 THERE IS/ARE SENTENCES

**Structure**:

```
there is + noun phrase
there are + noun phrase
```

**Purpose**: Introduce objects without requiring a verb

**Examples**:

```
There is a customer.
There are at least 3 apples.
```

---

### 2.3 ADDING DETAIL TO SENTENCES

#### Adjectives

```
A trusted customer inserts two valid cards.
There are two valid cards.
```

#### Possessives and Of-phrases

```
John's customer inserts a card of Mary.
```

#### Variables as Appositions

```
John inserts a card A.
```

#### Relative Clauses

```
A customer who is trusted inserts a card that he owns.
There are at least 2 cards that are valid.
```

#### Adverbs

```
A customer inserts some cards manually.
```

#### Prepositional Phrases

```
A customer inserts some cards into an ATM.
```

#### Combined Example

```
John's customer who is trusted inserts a valid card of Mary manually into an ATM A.
```

---

### 2.4 COMPOSITE SENTENCES

Built recursively through: coordination, subordination, quantification, negation

---

#### 2.4.1 Coordination

**AND**: Between sentences and phrases of same syntactic type

```
A customer inserts a card and the machine checks the code.
A customer inserts a card and enters a code.
An old and trusted customer enters a card and a code.
```

Note: "a card and a code" = plural object

**OR**: Between sentences, verb phrases, relative clauses

```
A customer inserts a card or the machine checks the code.
A customer inserts a card or enters a code.
A customer owns a card that is invalid or that is damaged.
```

**Binding Order**: AND binds stronger than OR (standard logic)

- Use commas to override binding order

**Example**:

```
A customer inserts a VisaCard or inserts a MasterCard and inserts a code.
```

Means: (VisaCard AND code) OR (MasterCard AND code)

---

#### 2.4.2 Subordination

**If-Then Sentences**: Conditional/hypothetical situations

```
If a card is valid then a customer inserts it.
```

Note: Anaphoric reference "it" refers to "a card"

**Modality**: Express possibility and necessity

```
A trusted customer can insert a card.
It is necessary that a trusted customer inserts a card.
```

**Sentence Subordination**: Sentences as objects of transitive verbs

```
It is false that a customer inserts a card.
It is not provable that a customer inserts a card.
A clerk believes that a customer inserts a card.
A clerk intends to enter a card. (= A clerk intends that the clerk enters a card.)
```

---

#### 2.4.3 Quantification

**Universal Quantification**: All objects of a class
**Existential Quantification**: At least one object of a class

**Scope Rule**: Extends to end of sentence or coordinated sentence

**Examples**:

```
Every customer inserts a card.
```

→ Each customer inserts a card (possibly different cards)

```
A card is inserted by every customer.
There is a card that every customer inserts.
```

→ All customers insert the SAME card

```
Every card is inserted by a customer.
```

→ Every card has a customer who inserts it

---

#### 2.4.4 Negation

**Standard Negation**: Express something is not the case

```
A customer does not insert a card.
A card is not valid.
```

**Universal Negation**: Using "no"

```
No customer inserts more than 2 cards.
```

**Universal Negation**: Using "there is no"

```
There is no customer who inserts a card.
```

**Sentence Negation**: Negate complete statement

```
It is false that a customer inserts a card.
```

**Negation as Failure**: Cannot be proved (no information available)

```
It is not provable that a customer inserts a card.
```

---

### 2.5 INTERROGATIVE SENTENCES

**Requirement**: Must end with question mark (?)

---

#### Yes/No Queries

Ask for existence/non-existence of specified situation

```
Does a customer insert a card?
Is John a customer?
```

---

#### Wh-Queries

Interrogate for details using query words

**Given statement**:

```
A trusted customer inserts a valid card manually.
```

**Possible queries**:

```
Who inserts a card?
Which customer inserts a card?
What does a customer insert?
How does a customer insert a card?
```

Note: Cannot query the verb

---

#### How Much/Many Queries

Ask for amounts or numbers

**Given statement**:

```
A customer owns 2 kg of gold.
```

**Query**:

```
How many customers own how much gold?
```

---

### 2.6 IMPERATIVE SENTENCES

**Structure**: `noun phrase (addressee) + comma + uncoordinated verb phrase + exclamation mark`

**Examples**:

```
John, go to the bank!
John and Mary, wait!
Every dog, bark!
John's brother, give the book to Mary!
```

---

## 3. CONSTRAINING AMBIGUITY

### Three Strategies

1. Exclude ambiguous constructs; provide unambiguous alternatives
2. Interpret remaining ambiguities deterministically via interpretation rules
3. Users accept interpretation or rephrase

---

### 3.1 AVOIDANCE OF AMBIGUITY

**Problem**: Relative clauses with coordinations

**Ambiguous (in natural English)**:

```
A customer inserts a card that is valid and opens an account.
```

Who opens the account?

**ACE Interpretation**: Customer opens the account

```
Paraphrase:
There is a customer X1. There is a card X2. The card X2 is valid.
The customer X1 inserts the card X2. The customer X1 opens an account.
```

**Alternative**: Card opens the account (repeat relative pronoun)

```
A customer inserts a card that is valid and that opens an account.

Paraphrase:
There is a customer X1. There is a card X2. The card X2 is valid.
The customer X1 inserts the card X2. The card X2 opens an account.
```

---

### 3.2 INTERPRETATION RULES

**Example**: Prepositional phrase attachment

**Statement**:

```
A customer inserts a card with a code.
```

**Default Interpretation**: "with a code" attaches to verb "inserts"

**Alternative 1**: Associate code with card (use relative clause)

```
A customer inserts a card that carries a code.

Paraphrase:
There is a card X1. There is a customer X2.
The customer X2 inserts the card X1. The card X1 carries a code.
```

**Alternative 2**: Customer inserts both card and code

```
A customer inserts a card and a code.
```

---

## 4. ANAPHORIC REFERENCES

### Purpose

Link references across sentences to refer to same entities

---

### 4.1 DEFINITE ARTICLES

**Without anaphora**:

```
A customer enters a card and a code.
If a code is valid then the ATM accepts a card.
```

→ Different card and code instances

**With anaphora (definite article)**:

```
A customer enters a card and a code.
If the code is valid then the ATM accepts the card.
```

→ Same card and code instances

---

### 4.2 RESOLUTION RULES

**"Most Recent and Most Specific"**:

**Example**:

```
A customer enters a red card and a blue card.
```

**Reference**:

```
The card is correct.
```

→ Refers to blue card (most recent)

**Reference**:

```
The red card is correct.
```

→ Refers to red card (most specific match)

---

### 4.3 ACCESSIBILITY CONSTRAINTS

**Inaccessible Contexts**: Noun phrases introduced in these contexts CANNOT be referenced anaphorically in subsequent sentences:

- If-then sentences
- Universally quantified sentences
- Negations
- Modality expressions
- Subordinated sentences

**Examples of INACCESSIBLE references**:

```
If a customer owns a card then he enters it.
Every customer enters a card.
A customer does not enter a card.
A customer can enter a card.
A clerk believes that a customer enters a card.
```

**Invalid subsequent reference**:

```
The card is correct.
```

→ CANNOT refer to "a card" from any of the above sentences

---

### 4.4 ANAPHORIC REFERENCE MECHANISMS

#### Personal Pronouns

```
A customer enters a card and a code.
If it is valid then the ATM accepts the card.
```

#### Variables

```
A customer enters a card X and a code Y.
If Y is valid then the ATM accepts X.
```

#### Combined (Definite Articles + Variables)

```
A customer enters a card X and a code Y.
If the code Y is valid then the ATM accepts the card X.
```

#### Proper Names

```
John
```

→ Always refers to the same entity throughout the text

---

## SUMMARY: KEY PRINCIPLES

1. **Unambiguous**: ACE eliminates or deterministically resolves ambiguities
2. **Structured**: Clear syntax rules for sentence construction
3. **Logical**: Maps directly to formal logic representations
4. **Controlled**: Limited vocabulary and grammatical constructs
5. **Anaphoric**: Explicit rules for cross-sentence references
6. **Parsable**: APE generates formal paraphrases showing interpretation

---
