type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

let accept_all derivation string = Some (derivation, string)

let awkish_grammar =
  (Expr,
   function
     | Expr ->
         [[N Term; N Binop; N Expr];
          [N Term]]
     | Term ->
	 [[N Num];
	  [N Lvalue];
	  [N Incrop; N Lvalue];
	  [N Lvalue; N Incrop];
	  [T"("; N Expr; T")"]]
     | Lvalue ->
	 [[T"$"; N Expr]]
     | Incrop ->
	 [[T"++"];
	  [T"--"]]
     | Binop ->
	 [[T"+"];
	  [T"-"]]
     | Num ->
	 [[T"0"]; [T"1"]; [T"2"]; [T"3"]; [T"4"];
	  [T"5"]; [T"6"]; [T"7"]; [T"8"]; [T"9"]])

let awksub_rules =
   [Expr, [T"("; N Expr; T")"];
    Expr, [N Num];
    Expr, [N Expr; N Binop; N Expr];
    Expr, [N Lvalue];
    Expr, [N Incrop; N Lvalue];
    Expr, [N Lvalue; N Incrop];
    Lvalue, [T"$"; N Expr];
    Incrop, [T"++"];
    Incrop, [T"--"];
    Binop, [T"+"];
    Binop, [T"-"];
    Num, [T"0"];
    Num, [T"1"];
    Num, [T"2"];
    Num, [T"3"];
    Num, [T"4"];
    Num, [T"5"];
    Num, [T"6"];
    Num, [T"7"];
    Num, [T"8"];
    Num, [T"9"]]

let awksub_grammar = Expr, awksub_rules

(* test convert_grammar *)
(* grammars and rules taken from class site. note awkish_grammar isnt exactly the same as awksub_grammar *)
let convert_grammar_test0 = 
	(snd (convert_grammar awksub_grammar) Incrop = snd awkish_grammar Incrop)

(* test parse_prefix *)
type dangling_else_nonterminals = 
	| Expr | ElseExpr

let dangling_else_gram =
	(Expr,
		function
		| Expr -> 
			[[T"if"; N Expr; T"then"; N Expr];
			[T"if"; N Expr; T"then"; N Expr; T"else"; N Expr];
			[N ElseExpr];
			[T"True"];
			[T"False"]]
		| ElseExpr -> [[T"else"; N ElseExpr]]
	)

let dangling_else_gram2 =
	(Expr,
		function
		| Expr -> 
			[[T"if"; N Expr; T"then"; N Expr; T"else"; N Expr];
			[T"if"; N Expr; T"then"; N Expr];
			[N ElseExpr];
			[T"True"];
			[T"False"]]
		| ElseExpr -> [[T"else"; N ElseExpr]]
	)


(* there is an else left unmatched if we use the first grammar *)
let test_1 = 
	(parse_prefix dangling_else_gram accept_all ["if"; "True"; "then"; "if"; "True";"then"; "True"; "else"; "False"] 
		= Some ([(Expr, [T "if"; N Expr; T "then"; N Expr]); (Expr, [T "True"]);
	   			(Expr, [T "if"; N Expr; T "then"; N Expr]); (Expr, [T "True"]);
	   			(Expr, [T "True"])],
	  			["else"; "False"]))

(* there is no dangling else if we use grammar2 which has the rules concering the else statement swapped with the one with no else *)
let test_2 = 
	(parse_prefix dangling_else_gram2 accept_all ["if"; "True"; "then"; "if"; "True";"then"; "True"; "else"; "False"]
		= Some ([(Expr, [T "if"; N Expr; T "then"; N Expr; T "else"; N Expr]);
	     		(Expr, [T "True"]); (Expr, [T "if"; N Expr; T "then"; N Expr]);
	     		(Expr, [T "True"]); (Expr, [T "True"]); (Expr, [T "False"])],
	    		[]))
