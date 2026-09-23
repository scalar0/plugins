# ACE 6.7 Interpretation Rules

**Source:** [ACE 6.7 Interpretation Rules](https://attempto.ifi.uzh.ch/site/docs/ace_troubleshooting.html)
**Purpose:** Define unambiguous interpretation rules for ACE sentences

## Overview

Each ACE sentence has only one meaning. While full English allows multiple interpretations, ACE applies specific rules to eliminate ambiguity.

**Notation:**

- `{...}` - indicates scope boundaries
- `[...]` - indicates anaphoric references
- `*` prefix - marks invalid ACE constructs (counter-examples)

---

## 1. Plurals

### Rule: Collective vs Distributive Reading

**Default:** Plural noun phrases have **collective reading**  
**Distributive:** Explicitly use `each of`

**Examples:**

```ace
Collective:    A clerk enters two cards.
Distributive:  A clerk enters each of two cards.
```

**Semantic Difference:**

```ace
Two girls lift a table.
→ One act of lifting; two girls together lift one table
→ One relation between two girls and one table

Each of two girls lifts a table.
→ Two acts of lifting; each girl individually lifts a table (possibly different)
→ Two relations between each girl and a table
```

---

## 2. Of-Constructs

### Rule: Definite + Of-Construct = Non-Functional Relation

A definite noun phrase followed by `of`-construct does NOT introduce a functional relation.

**Example:**

```ace
the father of John
→ Interpreted as: a father of John (not necessarily unique)
```

### Rule: Of-Construct Pertains to Complete Conjunction

An `of`-construct followed by a noun phrase conjunction applies to the **entire conjunction**.

**Examples:**

```ace
A man sees a dog of Mary and John.
→ Interpreted as: A man sees a dog of {Mary and John}
→ The dog belongs to BOTH Mary and John

A man sees John and a dog of Mary.
→ The man sees John AND (separately) a dog of Mary
```

---

## 3. Adjuncts

### 3.1 Prepositional Phrases

**Rule:** Prepositional phrases modify the **verb**, not the noun.

```ace
A customer enters a card with a code.
→ Interpreted as: A customer {enters a card with a code}
→ NOT: A customer enters {a card with a code}
```

### 3.2 Adverbs

**Rule:** When an adverb can modify the preceding OR following verb, it modifies the **preceding** verb.

```ace
A customer who enters a card manually types a code.
→ Interpreted as: A customer who {enters a card manually} types a code
```

---

## 4. Coordination

### 4.1 Relative Clauses

**Rule:** Relative clauses modify the **immediately preceding noun**.

To coordinate within a relative clause, **repeat** the relative pronoun (`who`/`that`/`which`).

**Examples:**

```ace
A customer enters a card that carries a code and opens an account.
→ Interpreted as: A customer enters {a card that carries a code} and opens an account

A customer inserts a card that is valid and that has a code.
→ Both conditions apply to the card
```

### 4.2 Binding Order

**Operator Precedence:**

```
and  >  or  >  ,and  >  ,or
```

- `and` binds stronger than `or`
- Comma-prefixed coordinators bind weaker
- Use commas to reverse default precedence

**Example:**

```ace
A client enters a red card or enters a blue card and enters a code.
→ Interpreted as: A client {enters a red card or enters a blue card} and enters a code
```

---

## 5. Scope of Subordinated Sentences

### 5.1 Sentence Subordination

**Rule:** The scope of simple subordinated sentences (following `that`) extends to the **end of the simple sentence**.

To coordinate within subordination scope, **repeat** `that`.

**Examples:**

```ace
It is false that a man waits and a dog barks.
→ Interpreted as: {It is false that a man waits} and a dog barks

It is false that a man waits and that a dog barks.
→ Both clauses are within the negation scope

John believes that Mary is tired and she sleeps.
→ John believes {that Mary is tired} and she sleeps (outside belief scope)

John believes that Mary is tired and that she sleeps.
→ Both clauses are within John's belief
```

### 5.2 If-Then Sentences

**Rule:** In `if-then` sentences, both the condition and conclusion can be coordinated, but they must match structurally.

**Examples:**

```ace
If a card is valid then a customer inserts it.
If a card is valid and expired then a customer must renew it.
If a card is valid or new then a customer can use it.
```

### 5.3 Modal and Temporal Auxiliaries

**Rule:** Scope of modal/temporal auxiliaries is the verb phrase.

**Examples:**

```ace
A customer must enter a card and enter a code.
→ Both actions are obligatory

A customer can enter a card or use a check.
→ Either action is permitted
```

### 5.4 Negation

**Rule:** Negation (`does not`, `is not`) applies to the immediately following verb or adjective.

**Examples:**

```ace
John does not provably sleep.
→ Negation applies to the entire predicate "provably sleep"

John provably does not sleep.
→ Provability applies to the negated predicate "does not sleep"
```

### 5.5 Quantifiers and Modality

**Rule:** Negation takes priority over modality/quantifiers in flat structure.

**Examples:**

```ace
There is no code that is valid.
→ No valid codes exist

It is not possible that a code is valid.
→ Validity is impossible for codes
```

---

## 6. Quantification

### 6.1 Existential Quantification

**Rule:** Indefinite noun phrases (`a`, `an`, `some`) introduce existential quantification.

**Scope:** Extends to the end of the sentence or coordination unit.

### 6.2 Universal Quantification

**Rule:** Universal noun phrases (`every`, `all`, `each`) have scope over the rest of the sentence.

**Examples:**

```ace
Every customer enters a card.
→ For each customer, there exists a card that the customer enters

A clerk checks every card.
→ There exists a clerk who checks all cards
```

### 6.3 Cardinality Constraints

**Rule:** Numeric quantifiers (`two`, `three`, etc.) specify exact cardinality by default.

**Examples:**

```ace
A customer enters two cards.
→ The customer enters exactly two cards

A customer enters at least two cards.
→ The customer enters two or more cards

A customer enters at most two cards.
→ The customer enters zero, one or two cards
```

---

## 7. Anaphoric References

### 7.1 Accessibility of Antecedents

**Rule:** An antecedent is **accessible** to an anaphor if:

- It occurs in the same sentence as the anaphor, OR
- It occurs in a preceding sentence

**Examples:**

```ace
A customer enters a card. The card is valid.
→ "The card" refers to the previously mentioned card

If a customer owns a card then he enters it.
→ "he" refers to "a customer"; "it" refers to "a card"
```

### 7.2 Non-Reflexive Pronouns

**Rule:** Non-reflexive pronouns (`he`, `him`, `his`, `she`, `her`, `it`, `they`, `them`) resolve to the **most recent accessible** noun phrase that:

- Agrees in gender and number
- Is NOT the subject of the verb phrase containing the pronoun

**Examples:**

```ace
John has a card. Bob sees him and takes it.
→ "him" = John; "it" = the card

John and Mary wait. They are tired.
→ "They" = John and Mary

* John sees his wife.
→ Invalid: use "John sees his own wife" instead
```

**Special Case - Conjunctions:**

```ace
John and two friends walk. They are tired.
→ "They" = John and two friends
```

### 7.3 Reflexive Pronouns

**Rule:** Reflexive pronouns (`herself`, `himself`, `themselves`, `her own`, `his own`) resolve to the **subject** of the sentence containing the pronoun, provided gender and number agree.

**Examples:**

```ace
Mary takes her own card and gets some money for herself.
→ Both reflexives refer to Mary

John and Mary admire themselves.
→ Reflexive refers to the conjunction "John and Mary"

John sees a man that sees himself.
→ "himself" = the man (subject of relative clause)

John sees a man that is seen by himself.
→ "himself" = the man (subject of passive relative clause)
```

### 7.4 Definite Noun Phrases

**Rule:** Definite noun phrases resolve to the **most recent and most specific** accessible antecedent that agrees in gender and number.

**Specificity Hierarchy:**

```ace
There is a blue ball. There is a red ball. John sees the ball.
→ "the ball" = the red ball (most recent)
→ Mary sees the blue ball (explicitly specified)

There is a ball of a boy. There is a ball of a girl.
John sees the ball.
→ "the ball" = the ball of a girl (most recent)
→ Mary sees the ball of a boy (explicitly specified)

There is a ball that is blue. There is a ball that is red.
John sees the ball.
→ "the ball" = the ball that is red (most recent)
→ Mary sees the ball that is blue (explicitly specified)
```

**Resolution by Specificity:**

```ace
There is a man. His dog barks. The man whose dog barks is irritated.
→ Valid: the definite phrase matches the described antecedent structure

A man owns a dog. John sees the man who owns a dog.
→ Valid: the definite phrase includes all antecedent constituents
```

**Unresolved Definites:**

**Rule:** If a definite noun phrase cannot be resolved, it is interpreted as an **indefinite noun phrase** introducing a new entity.

```ace
John goes to the bank.
→ "the bank" has no antecedent → introduces a new entity
```

### 7.5 Variables

**Rule:** Variable anaphors resolve to an accessible noun phrase that:

- Has the variable as apposition, OR
- Is the respective "bare" variable

**Examples:**

```ace
John has a card X and a card Y. Mary takes the card. Bob takes the card X. Harry takes Y.
→ "the card" = unspecified; "the card X" = specific card X; "Y" = card Y

X is heavy. John lifts X.
→ Equivalent to: Something X is heavy. John lifts X.
```

### 7.6 Undefined Capitalized Words

**Rule:** An undefined word starting with a capital letter in noun phrase position is interpreted as a **singular proper name** with **undefined gender**.

Gender is determined by subsequent pronoun reference.

**Examples:**

```ace
Leonino sleeps.
→ Gender of "Leonino" is undefined

Leonino sleeps. Her fur is wet.
→ "Her" assigns female gender to "Leonino"
→ All subsequent references must respect this gender
```

---

## 8. Passives

**Rule:** Passive sentences have the **same meaning** as their active counterparts.

**Examples:**

```ace
A card is entered by John.
→ Equivalent to: John enters a card

A customer is given a card by John.
→ Equivalent to: John gives a customer a card
```

**Important:** Passive sentences in ACE **always require** an agent denoted by `by ...`.

**Caution:** If a lexicon contains the same word as both:

- Participle perfect (used in passives), AND
- Intransitive adjective

Then sentences like `A card is entered.` are NOT passive (no `by` phrase) and `entered` is interpreted as an adjective.

---

## 9. Arithmetic Expressions

### 9.1 Operators and Precedence

**Operators:** `+`, `-`, `*`, `/`, `^`

**Precedence (high to low):**

```
^  (exponentiation)
*  /  (multiplication, division)
+  -  (addition, subtraction)
```

**Associativity:** All operators are **left-associative**

**Examples:**

```ace
2^3^4
→ Interpreted as: (2^3)^4 = 4096

Use parentheses to change:
2^(3^4)
→ 2^81
```

### 9.2 Types

**Rule:** All arguments to arithmetic operators must eventually stand for **numbers**.

**Note:** The ACE parser APE does **not evaluate** expressions.

---

## 10. Strings

### 10.1 String Syntax

**Format:** Sequence of Unicode characters enclosed in double quotes `"..."`

**Escaping:**

- Quotation marks within strings: `\"`
- Backslashes within strings: `\\`

### 10.2 String Concatenation

**Operator:** `&` (left-associative)

**Concatenable Elements:**

- Strings
- Variables
- Proper names
- Bracketed strings

### 10.3 Types

**Rule:** All arguments to the concatenation operator `&` must eventually stand for **strings**.

**Note:** The ACE parser APE does **not perform** concatenations.

---

## Summary of Key Principles

1. **Unambiguity:** Every ACE sentence has exactly one interpretation
2. **Recency:** Anaphoric references prefer most recent accessible antecedent
3. **Locality:** Modifiers attach to nearest valid target
4. **Explicitness:** Distributive readings, coordination scopes and reflexivity require explicit markers
5. **Type Safety:** Operators enforce type constraints on arguments
6. **Precedence:** Clear operator and coordinator precedence with override mechanisms

---

**Document Metadata:**

- Format: Markdown
- Optimized for: LLM parsing and reasoning
- Encoding: UTF-8
- Structure: Hierarchical with numbered sections
- Examples: Consistently formatted with explicit interpretations
