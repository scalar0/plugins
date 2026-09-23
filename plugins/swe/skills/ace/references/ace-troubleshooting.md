# ACE 6.7 Troubleshooting Guide

**Source**: [ACE 6.7 Troubleshooting Guide](https://attempto.ifi.uzh.ch/site/docs/ace_troubleshooting.html)

**Purpose**: This guide helps resolve common issues when writing ACE (Attempto Controlled English) texts. ACE expresses texts in a concise, unambiguous and easily understandable way, but requires practice.

**Notation**:

- `{...}` indicates semantic meaning (not ACE set notation)
- `*` prefix marks invalid ACE sentences (counter-examples)

---

## General Principles

### Construction Rules

**Basic Requirements**:

- Use only complete sentences with proper punctuation:
    - Declarative sentences end with `.`
    - Interrogative sentences end with `?`
    - Imperative sentences end with `!`
- Commas are only allowed:
    - Before _and_ or _or_
    - In specific positions within imperative sentences
    - In lists and sets
- No other punctuation is permitted
- Follow predefined ACE word order
- Every noun requires a determiner
- Comply with ACE function word definitions and interpretations

**Simplicity Guidelines**:

- Keep sentences short and simple
- Avoid unnecessarily complex coordinations
- Avoid complex combinations of negation, quantification and coordination
- Use multiple short sentences instead of one complex sentence
- Always specify agents for actions (use active voice or passive with "by ...")

### Interpretation Guidelines

- Be as explicit as possible
- Avoid ambiguous or misleading constructions
- Always verify the system's paraphrase matches your intended interpretation
- Reformulate if the paraphrase is incorrect
- When in doubt, consult the ACE interpretation rules

---

## Troubleshooting Process

When the Attempto system analyzes your text, two problems can occur:

1. The system rejects your text (or part of it)
2. The system accepts your text but the paraphrase doesn't match your intent

### Problem 1: Text Rejected by System

**Common Causes**:

#### Unknown or Misspelled Words

Check for:

- Misspelled words
- Undefined function words
- Undefined content words
- Incorrectly classified content words (wrong word class, type, number or complements)

**Solution**: Correct spelling and use defined words correctly.

#### Grammar Violations

**Tense Restrictions**:

- ✗ Do not use tenses other than simple present

**Word Order**:

- ✗ Do not put adverbs or prepositional phrases at the beginning of sentences

**Implications**:

- ✓ Always start with condition (`if`) followed by consequence (`then`)
- ✗ Do not add comma before `then`

**Coordination**:

- ✓ Only coordinate phrases of the same syntactic type

**Relative Clauses**:

- ✓ Always begin with `who`, `which` or `that`

**Determiners**:

- ✗ Do not use nouns without determiners

**Prepositional Phrases as Noun Modifiers**:

- ✗ Do not use prepositional phrases (except _of_-phrases) to modify nouns
- Example: `*A card in a slot is invalid.`
- ✓ Use relative clauses instead: `A card that is in a slot is invalid.`

**Passive Constructions**:

- ✓ Always add an agent: `A code is entered by a customer.`
- ✓ Or use active voice: `A customer enters the code.`

### Problem 2: Incorrect Interpretation

If the paraphrase doesn't match your intent, reformulate using these strategies:

#### Prepositional Phrases

**Issue**: Prepositional phrases as adjuncts modify the verb, not the noun.

**Example**:

```
Input: A bank accepts every card with a blue sign.
Interpretation: There is a bank. If there is a card then the bank accepts the card with a blue sign.
```

(Incorrect: "with a blue sign" modifies "accepts", not "card")

**Solution**: Use relative clause to modify noun:

```
Reformulation: A bank accepts every card that has a blue sign.
Interpretation: There is a bank. If there is a card and the card has a blue sign, then the bank accepts the card.
```

#### Anaphoric References

**Issue**: Anaphoric references can be ambiguous with multiple possible antecedents.

**Example**:

```
Input: A customer enters a card and a code. If it is not valid then SM rejects the card.
Interpretation: There is a customer. The customer enters a card and enters a code...
```

(Ambiguous: Does "it" refer to "card" or "code"?)

**Solution**: Use full noun phrase instead of pronoun:

```
Reformulation: A customer enters a card and a code. If the code is not valid then SM rejects the card.
```

#### Quantifiers and Scope

**Issue**: Quantifier scope affects interpretation.

**Universal Quantification Example**:

```
Input: Every customer enters a card.
Interpretation: If there is a customer then the customer enters a card.
```

(One card per customer)

```
Input: There is a card that every customer enters.
Interpretation: There is a card. If there is a customer then the customer enters the card.
```

(One shared card for all customers)

**Negation Example**:

```
Input: Every card is not valid.
Interpretation: If there is a card then it is false that the card is valid.
```

(Universal negation: no cards are valid)

```
Input: There is a card that is not valid.
Interpretation: There is a card. It is false that the card is valid.
```

(Existential negation: at least one invalid card exists)

**Strategy**: Use predicate logic identities for reformulation:

- "no" = "every ... not"
- Experiment with quantifier placement to achieve desired scope

---

## Common Mistakes and Solutions

### 1. Expressing Universal Statements

**Problem**:

```
*A cat is an animal.
```

**Issue**: `a` means existential quantification ("There is a cat. The cat is an animal.")

**Solution**:

```
Every cat is an animal.
```

(Interpretation: If there is a cat then the cat is an animal.)

### 2. Reflexive Pronouns

**Problem**:

```
John sees his wife.
```

**Issue**: `his` refers to a masculine noun from a previous sentence, not John.

**Solution**:

```
John sees his own wife.
```

### 3. Noun Phrase Disjunction

**Problem**:

```
*John enters a card or a code.
```

**Issue**: Disjunction of noun phrases not supported.

**Solution**:

```
John enters a card or enters a code.
```

### 4. There-is Sentences with Prepositional Phrases

**Problem**:

```
*There is a card in a slot.
```

**Issue**: _There-is_ sentences cannot be modified by prepositional phrases.

**Solution**:

```
A card is in a slot.
```

### 5. Adverb Modification

**Problem (adverbs modifying adverbs)**:

```
*John drives extremely carefully.
```

**Solution**: Coordinate adverbs:

```
John drives extremely and carefully.
```

**Problem (sentence-modifying adverbs)**:

```
*John only works.
```

**Issue**: Not supported in ACE.

### 6. Phrasal Verbs

**Problem**:

```
*John comes across an interesting story.
```

**Issue**: ACE prefers intransitive reading; analyzes as verb + prepositional phrase.

**Solution**: Hyphenate phrasal verb:

```
John comes-across an interesting story.
```

**Problem (particle movement)**:

```
*John looks up a word. He looks it up.
```

**Solution**: Keep particle with verb, hyphenated:

```
John looks-up a word. He looks-up it.
```

Note: While "He looks-up it" is valid in ACE, prefer:

```
He looks-up the word.
```

---

## Lexicon Issues

**Requirements**:

- All content words (nouns, verbs, adjectives, adverbs) must be defined in built-in or user-supplied lexicon
- User lexicons are searched first

**Multi-Class Words**:
Words belonging to multiple word classes must be defined for each class.

**Example**: "surface"

```
The surface of the lens is clean.        (noun)
Some surface impurities are removed.     (adjective)
The diver surfaces.                      (verb)
```

**Example**: Chemical elements (proper noun vs. mass noun)

```
Helium is an element.                    (proper noun)
The balloon contains 20 kg of helium.    (mass noun)
```

---

## Quick Reference: Do's and Don'ts

### ✓ DO:

- Use complete sentences with proper punctuation
- Use simple present tense only
- Start implications with `if ... then ...`
- Use relative clauses to modify nouns
- Specify agents for all actions
- Use determiners with all nouns
- Hyphenate phrasal verbs
- Check paraphrases match intent

### ✗ DON'T:

- Use tenses other than simple present
- Begin sentences with adverbs or prepositional phrases
- Use commas before `then` in implications
- Coordinate phrases of different syntactic types
- Use nouns without determiners
- Use prepositional phrases (except _of_) to modify nouns
- Use passive without agents
- Use noun phrase disjunction
- Use adverbs that modify other adverbs or whole sentences
- Move particles away from phrasal verbs

---
