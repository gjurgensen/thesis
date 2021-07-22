Require Import Ctl.Paths.

Require Import Coq.Relations.Relation_Definitions.

Inductive TProp state : Type :=
  | TTop  : TProp state
  | TBot  : TProp state
  | TLift : (state -> Prop) -> TProp state
  | TNot  : TProp state -> TProp state
  | TConj : TProp state -> TProp state -> TProp state
  | TDisj : TProp state -> TProp state -> TProp state
  | TImpl : TProp state -> TProp state -> TProp state
  | AX    : TProp state -> TProp state
  | EX    : TProp state -> TProp state
  | AF    : TProp state -> TProp state
  | EF    : TProp state -> TProp state
  | AG    : TProp state -> TProp state
  | EG    : TProp state -> TProp state
  | AU    : TProp state -> TProp state -> TProp state
  | EU    : TProp state -> TProp state -> TProp state.

(* Make state argument implicit *)
Arguments TTop  {state}%type_scope.
Arguments TBot  {state}%type_scope.
Arguments TLift {state}%type_scope.
Arguments TNot  {state}%type_scope.
Arguments TConj {state}%type_scope.
Arguments TDisj {state}%type_scope.
Arguments TImpl {state}%type_scope.
Arguments AX    {state}%type_scope.
Arguments EX    {state}%type_scope.
Arguments AF    {state}%type_scope.
Arguments EF    {state}%type_scope.
Arguments AG    {state}%type_scope.
Arguments EG    {state}%type_scope.
Arguments AU    {state}%type_scope.
Arguments EU    {state}%type_scope.

Notation "⊤" := (TTop).
Notation "⊥" := (TBot).
Notation "⟨ P ⟩" := (TLift P) (at level 35, format "⟨ P ⟩").
Notation "P ∧ Q" := (TConj P Q) (at level 45, right associativity).
Notation "P ∨ Q" := (TDisj P Q) (at level 55, right associativity).
Notation "P --> Q" := (TImpl P Q) (at level 68,  right associativity).
Notation "P <--> Q" := ((P --> Q) ∧ (Q --> P)) (at level 65,  right associativity).
Notation "¬ P" := (TNot P) (at level 40).
Notation "'A' [ P 'U' Q ]" := (AU P Q) (at level 40, format "'A' [ P  'U'  Q ]").
Notation "'E' [ P 'U' Q ]" := (EU P Q) (at level 40, format "'E' [ P  'U'  Q ]").

(* Add "W" operator?
   "Weak" until, AKA the "unless" operator. Like the until operator, but the
   second condition does not ever have to come true.
 *)

Reserved Notation "M @ s ⊨ P" (at level 70, format "M  @ s  ⊨  P").
Reserved Notation "M @ s ⊭ P" (at level 70, format "M  @ s  ⊭  P").
(* Replace binary_relation with serial_transition if needed *)
Fixpoint tEntails {state} (R: relation state) (s: state) (tp: TProp state) : Prop :=
  match tp with
  | ⊤ => True
  | ⊥ => False
  | ⟨P⟩ => P s
  | ¬P => R @s ⊭ P
  | P ∧ Q => R @s ⊨ P /\ R @s ⊨ Q
  | P ∨ Q => R @s ⊨ P \/ R @s ⊨ Q
  | P --> Q => R @s ⊨ P -> R @s ⊨ Q
  | AX P => forall s', R s s' -> R @s' ⊨ P
  | EX P => exists s', R s s' -> R @s' ⊨ P
  | AG P => forall n, forall p: path R n s, forall s', in_path s' p -> R @s' ⊨ P
  | EG P => forall n, exists p: path R n s, forall s', in_path s' p -> R @s' ⊨ P
  | AF P => exists n, forall p: path R n s, exists s', in_path s' p /\ R @s' ⊨ P
  | EF P => exists n, exists p: path R n s, exists s', in_path s' p /\ R @s' ⊨ P
  | A[P U Q] => forall n (p: path R n s),
      exists sQ i, in_path_at sQ i p /\ 
        R @sQ ⊨ Q /\
        forall sP, in_path_before sP i p -> R @sP ⊨ P
  | E[P U Q] => exists n (p: path R n s),
      exists sQ i, in_path_at sQ i p /\ 
        R @sQ ⊨ Q /\
        forall sP, in_path_before sP i p -> R @sP ⊨ P
  end
  where "M @ s ⊨ P" := (tEntails M s P)
    and "M @ s ⊭ P" := (~ M @s ⊨ P).
