Require Import Ctl.Paths.
Require Import Ctl.Definition.
Require Import Ctl.Tactics.
Require Import Ctl.Properties.

Require Import BinaryRelations.
Require Import SepLogic.
Require Import TransitionSystems.
Require Import AttarchTrans.

Require Import Coq.Program.Equality.
Require Import Coq.Relations.Relation_Definitions.
Require Import Coq.Relations.Relation_Operators.
Require Import GeneralTactics.

(* Assert some fact about the global state *)
Definition gassert {comp loc L} (s: sprop comp loc) : TProp (sprop comp loc * L) :=
    TLift (fun st => fst st ⊢ s \/ exists frame, fst st ⊢ s ** frame).

Theorem useram_key_never_compromised: forall (acc: access component),
  acc malicious_linux_component read ->
  attarch_strans; (empty, boot_from_good_plat) ⊨ ¬ EF (gassert (acc @ useram_key)).
Proof.
  intros acc Hmal_acc.

  (* Apply AG_EF. TODO, better version of tapply *)
  (* - Perhaps refular apply, followed by a smart fold? *)
  pose proof (AG_EF attarch_strans (empty, boot_from_good_plat) (gassert (acc @ useram_key))) as H.
  assert (H0:
      attarch_strans;(empty, boot_from_good_plat) ⊨ AG (¬(gassert (acc @ useram_key))) ->
      attarch_strans;(empty, boot_from_good_plat) ⊨ ¬EF (gassert (acc @ useram_key))
  ) by auto; apply H0; clear H0.
  clear H.

  apply rtc_AG.
  intros s' Hsteps.

  dependent induction Hsteps.
  - sentails.
  - intros Hcontra.
    invc H.
    invc H2.
    + inv Hcontra; sentails.
    + inv Hcontra; sentails.
    + invc H3. 
      (* platam_trans *)
      * invc H2; sentails.
      (* vm_trans *)
      * invc H2. 
        -- sentails.
        -- tapplyc IHHsteps.
           destruct or Hcontra; simpl in Hcontra.
           ++ left.
              sentails.
           ++ right.
              destruct exists Hcontra frame.
              exists frame.
              sentails.
Qed.