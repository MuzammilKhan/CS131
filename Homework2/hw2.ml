type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(* 1 *)
(* using tail recursion *)
let rec find_alternative_list rules nonterminal result = match rules with
  | [] -> List.rev result (* or should it be [[]] instead? *)
  | h::t -> if((fst h) = nonterminal)
               then (find_alternative_list t nonterminal ((snd h)::result))
            else find_alternative_list t nonterminal result

let convert_grammar gram1 = match gram1 with
  | (start, rules) -> (start, (fun x -> (find_alternative_list rules x []))) (* or [[]] ?*)

(* 2 *)

let rec  make_appended_matchers make_a_matcher rule accept deriv frag = match rule with
  | [] -> accept deriv frag (* return match *)
  | rule_h::rule_t -> match frag with
    | [] -> None (*frag empty or exhausted *)
    | frag_h::frag_t -> match rule_h with
      | N(nonterminal) -> (make_or_matcher make_a_matcher nonterminal (make_a_matcher nonterminal) (make_appended_matchers make_a_matcher rule_t accept) deriv frag)
                          (* check starting from nonterminal, add nonterminal to acceptor *)
      | T(terminal) -> if frag_h = terminal
                          then make_appended_matchers make_a_matcher rule_t accept deriv frag_t (*check if the tail matches*)
                       else None

and make_or_matcher make_a_matcher symbol rules accept deriv frag = match rules with
  | [] -> None  (* rules empty or exhausted*)
  | head::tail -> let ormatch =  make_appended_matchers make_a_matcher head accept (deriv@[symbol,head]) frag
                      in match ormatch with
                      | None -> make_or_matcher make_a_matcher symbol tail accept deriv frag (* try next rule *)
                      | Some _ -> ormatch (*append match worked *)

let parse_prefix grammar accept frag = match grammar with
  | (start, prodfunction) -> match (prodfunction start) with
    | [] -> None
    | rules -> make_or_matcher prodfunction start rules accept [] frag
