(* 1 *)
let rec exists x s = match s with
  | [] -> false
  | h::t -> if x = h
               then true
               else (exists x t);;

let rec subset a b = match a with
  | [] -> true (* empty set is subset of all sets*) 
  | h::t -> (exists h b) && (subset t b);;

(* 2 *)
let rec equal_sets a b = subset a b && subset b a;;

(* 3 *)
let rec set_union a b = match a with
  | [] -> b
  | h::t -> if (exists h b)
               then (set_union t b)
               else (set_union t b@[h]);;

(* 4 *)
let rec set_intersection a b = match a with
  | [] -> []
  | h::t -> if (exists h b)
               then (set_intersection t b) @ [h]
               else (set_intersection t b);;

(* 5 *)
let rec set_diff a b = match a with
  | [] -> []
  | h::t -> if (exists h b)
               then (set_diff t b)
               else (set_diff t b) @ [h];;

(* 6 *)
let rec computed_fixed_point eq f x =
  if (eq (f x) x)
     then x
     else computed_fixed_point eq f (f x);;

(* 7 *) (* What about negative numbers for p*)
let rec computed_periodic_point eq f p x = match p with
  | 0 -> x 
  | _ -> if eq (f(computed_periodic_point eq f (p - 1) (f x))) x
            then x
            else (computed_periodic_point eq f p (f x));;

(* 8 *)
let rec while_away s p x =
  if p x
     then [x] @ (while_away s p (s x)) 
     else [];;

(* 9 *)
let rec repeat (a, b) = match a with  (* repeat b a times *) (* negative a?*)
  | 0 -> []
  | _ -> (repeat ((a - 1), b)) @ [b];; 

let rec rle_decode lp = match lp with
  | [] -> []
  | h::t -> (repeat h) @ (rle_decode t);;

(* 10 *)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

let is_symbol_valid valid_nonterminals = function
  | N symbol -> subset [symbol] valid_nonterminals 
  | T symbol -> true;;

let rec is_rhs_valid valid_nonterminals = function
  | [] -> true
  | h::t -> if is_symbol_valid valid_nonterminals h 
	       then is_rhs_valid valid_nonterminals t 
            else false;;

let rec filter_invalid_rules valid_nonterminals = function
  | [] -> []
  | (a, b)::t -> if is_rhs_valid valid_nonterminals b 
		    then (a, b)::(filter_invalid_rules valid_nonterminals t) 
                 else filter_invalid_rules valid_nonterminals t;;

let rec find_valid_rules_helper  symbols  = function
  | [] -> symbols
  | (a, b)::t -> if is_rhs_valid symbols b
                     then if   subset [a] symbols (*check if symbol already added *)
                               then (find_valid_rules_helper symbols t)
                          else (find_valid_rules_helper (a::symbols)  t)
                 else find_valid_rules_helper symbols t;;


let find_valid_rules (symbols, rules) =
  (find_valid_rules_helper symbols rules), rules;;

let find_valid_nonterminals (valid_rules, rules) = 
  fst(computed_fixed_point (fun (a,_) (b, _) -> equal_sets a b) find_valid_rules ([], rules));;

let filter_blind_alleys g  = match g with
 | (start,rules) -> (start, filter_invalid_rules (find_valid_nonterminals ([], rules)) rules);;
