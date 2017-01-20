%remove first N elements from L and return S
trim(L, N, S) :- length(P, N), append(P, S, L).

%remove last N elements and return P
trim_last(L,N,P) :- length(S,N), append(P,S,L).

%count the first occurences of X in a list (second parameter) and stop when the chars change to something other than X
count(_, [], 0) :- !. 
count(X, [X|T], N) :- count(X, T, N1), N is N1 + 1.     
count(X, [Y|_], N) :- X \= Y,  !, N is 0. 

%take input morse binary and return morse as letters
signal_morse([],[]) :- !.
signal_morse([H|_],_) :- H \= 0, H \= 1, !.
signal_morse(L, M) :- L = [1|_] , count(1, L, Count) , Count >= 3 , trim(L, Count, T) , signal_morse(T, X) , append( [-] , X , M ). 
signal_morse(L, M) :- L = [1|_] , count(1, L, Count) , Count = 2 , L = [_,_|T], signal_morse(T, X) , append( [.] , X , M ). %try to match with '.'' , if it fails then '-'
signal_morse(L, M) :- L = [1|_] , count(1, L, Count) , Count = 2 , L = [_,_|T], signal_morse(T, X) , append( [-] , X , M ).
signal_morse(L, M) :- L = [1|_] , count(1, L, Count) , Count = 1 , L = [_|T],   signal_morse(T, X) , append( [.] , X , M ).

signal_morse(L, M) :- L = [0|_] , count(0, L, Count) , Count > 5 , trim(L, Count, T) , signal_morse(T, X) , append( ['#'] , X , M ). 
signal_morse(L, M) :- L = [0|_] , count(0 ,L, Count) , Count = 5 , L = [_,_,_,_,_|T], signal_morse(T, X) , append( [^] , X , M ). %try to match ^ then #
signal_morse(L, M) :- L = [0|_] , count(0 ,L, Count) , Count = 5 , L = [_,_,_,_,_|T], signal_morse(T, X) , append( ['#'],X  , M).
signal_morse(L, M) :- L = [0|_] , count(0 ,L, Count) , Count = 4 , L = [_,_,_,_|T],   signal_morse(T, X) , append( [^] , X , M  ).
signal_morse(L, M) :- L = [0|_] , count(0 ,L, Count) , Count = 3 , L = [_,_,_|T],     signal_morse(T, X) , append( [^] , X , M  ).
signal_morse(L, M) :- L = [0|_] , count(0 ,L, Count) , Count = 2 , L = [_,_|T],       signal_morse(T, M).
signal_morse(L, M) :- L = [0|_] , count(0 ,L, Count) , Count = 2 , L = [_,_|T],       signal_morse(T, X) , append( [^] , X , M  ). 
signal_morse(L, M) :- L = [0|_] , count(0, L, Count) , Count = 1 , L = [_|T],         signal_morse(T, M).

%translate morse to letters
morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).       % B
morse(c, [-,.,-,.]).       % C
morse(d, [-,.,.]).     % D
morse(e, [.]).         % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).       % F
morse(g, [-,-,.]).     % G
morse(h, [.,.,.,.]).       % H
morse(i, [.,.]).       % I
morse(j, [.,-,-,-]).       % J
morse(k, [-,.,-]).     % K or invitation to transmit
morse(l, [.,-,.,.]).       % L
morse(m, [-,-]).       % M
morse(n, [-,.]).       % N
morse(o, [-,-,-]).     % O
morse(p, [.,-,-,.]).       % P
morse(q, [-,-,.,-]).       % Q
morse(r, [.,-,.]).     % R
morse(s, [.,.,.]).     % S
morse(t, [-]).         % T
morse(u, [.,.,-]).     % U
morse(v, [.,.,.,-]).       % V
morse(w, [.,-,-]).     % W
morse(x, [-,.,.,-]).       % X or multiplication sign
morse(y, [-,.,-,-]).       % Y
morse(z, [-,-,.,.]).       % Z
morse(0, [-,-,-,-,-]).     % 0
morse(1, [.,-,-,-,-]).     % 1
morse(2, [.,.,-,-,-]).     % 2
morse(3, [.,.,.,-,-]).     % 3
morse(4, [.,.,.,.,-]).     % 4
morse(5, [.,.,.,.,.]).     % 5
morse(6, [-,.,.,.,.]).     % 6
morse(7, [-,-,.,.,.]).     % 7
morse(8, [-,-,-,.,.]).     % 8
morse(9, [-,-,-,-,.]).     % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error 

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)

%split list by the first occurance of the delimiter and return the prefix and suffix
split(_, [], [], _) :- !. %split
split(Term, [Term|Tail], [], Tail).
split(Term, [Head|Tail], [Head|Result], Remainder) :- split(Term, Tail, Result, Remainder), !.

%translate morse word to letters
word([],[]) :- !.
word(L, W) :- split(^, L, L2, R2), word(R2, W2) , morse(A, L2), !, append([A], W2, W).

%translate more sentence to letters
sentence_helper([],[]) :- !. 
sentence_helper(L, W) :- split('#', L, L2, R2), sentence_helper(R2, W2) , word(L2, A), append(A, ['#'], A2), !, append(A2, W2, W). %adds an extra # at the end. need to remove it. !!!!!!!!!!!!!!!!!!!
sentence(L,W) :- sentence_helper(L,W1), trim_last(W1,1,W).

%clean errors at word level
clean_help([], []) :- !.
clean_help([error], [error]) :- !.
clean_help(L, C) :- L = [error,error|R] , clean_help(R, C) , !.
clean_help(L, C) :- L = [error|R], clean_help(R,C2), append([error], C2, C), !.
clean_help(L, C) :- split(error, L, L1 , R) , L1 \= [], R \= [], clean_help(R, C) , !.
clean_help(L, C) :- last(L, error), split(error, L, L1 , R) , L1 \= [], R = [], clean_help(R, C) , !.
clean_help(L, L) :-  !.

%clean error at sentence level and call clean_help to clean the word levels
clean([],[]) :- !.
clean(L, C) :- split('#', L, _ , R), R = [], clean_help(L, C) , !.
clean(L, C) :- split('#', L, L2, R2), R2 \= [error|_], clean(R2, C2), clean_help(L2, C1), append(C1, ['#'], C1hash) , !, append(C1hash, C2, C), !.
clean(L, C) :- split('#', L, _ , R2), R2 = [error|R3], clean(R3, C), !.

%convert morse binary to letters
signal_message([],[]) :- !.
signal_message(L, M) :- signal_morse(L,S), sentence(S, T), clean(T,M).