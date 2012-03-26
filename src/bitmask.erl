%%%  bitmask:in($t, bitmask:append_list("test", bitmask:new(255))).
-module(bitmask).
-export([new/1,
         new/2,
         from_binary/1,
         union/2,
         subtract/2,
         intersection/2,
         inverse/1,
         insert/2,
         delete/2,
         in/2
        ]).

-export([to_list/1, append_list/2, bits/1]).

-record(bitmask, {
    bin :: binary(),
    from = 1 :: integer(),
    size :: integer()
}).


-define(POS_TO_SEEK(From, Pos), (Pos-From)).
-define(INT_TO_BOOL(X), (case X of 0 -> false; 1 -> true end)).

-type position() :: non_neg_integer().
-type bitmask() :: bitstring().

new(Size) -> #bitmask{size=Size, bin = <<0:Size>>}.
new(Size, From) -> #bitmask{size=Size, from=From, bin = <<0:Size>>}.

from_binary(B) -> 
    S = bit_size(B),
    #bitmask{size=S, bin=B}.

from_binary(B, F) -> 
    S = bit_size(B),
    #bitmask{size=S, from=F, bin=B}.

union(#bitmask{size=Size, bin=B1}=M1, 
      #bitmask{size=Size, bin=B2}) ->
    <<V1:Size>> = B1,
    <<V2:Size>> = B2,
    V3 = V1 bor V2,
    B3 = <<V3:Size>>,
    M1#bitmask{bin=B3}.

%% difference
subtract(#bitmask{size=Size, bin=B1}=M1, 
         #bitmask{size=Size, bin=B2}) ->
    <<V1:Size>> = B1,
    <<V2:Size>> = B2,
    V3 = (V1 bxor V2) band V1,
    B3 = <<V3:Size>>,
    M1#bitmask{bin=B3}.

intersection(#bitmask{size=Size, bin=B1}=M1, 
             #bitmask{size=Size, bin=B2}) ->
    <<V1:Size>> = B1,
    <<V2:Size>> = B2,
    V3 = V1 band V2,
    B3 = <<V3:Size>>,
    M1#bitmask{bin=B3}.

inverse(#bitmask{size=Size, bin=B1}=M1) ->
    <<V1:Size>> = B1,
    V2 = not V1,
    B2 = <<V2:Size>>,
    M1#bitmask{bin=B2}.

-spec insert(position(), bitmask()) -> bitmask().
insert(P, #bitmask{from=F, bin=B}=M1) when is_integer(P) -> 
    S = ?POS_TO_SEEK(F, P),
         <<Start:S, _:1, End/bitstring>> = B,
    B3 = <<Start:S, 1:1, End/bitstring>>,
    M1#bitmask{bin=B3}.

-spec delete(position(), bitmask()) -> bitmask().
delete(P, #bitmask{from=F, bin=B}=M1) when is_integer(P) ->
    S = ?POS_TO_SEEK(F, P),
         <<Start:S, _:1, End/bitstring>> = B,
    B3 = <<Start:S, 0:1, End/bitstring>>,
    M1#bitmask{bin=B3}.

in(P, #bitmask{from=F, bin=B}) when is_integer(P) ->
    S = ?POS_TO_SEEK(F, P),
    <<_Start:S, X:1, _End/bitstring>> = B,
    ?INT_TO_BOOL(X).

to_list(#bitmask{from=F, bin=B}) ->
    do_list(F, B, []).

do_list(F, <<1:1, T/bitstring>>, Acc) -> do_list(F+1, T, [F|Acc]);
do_list(F, <<0:1, T/bitstring>>, Acc) -> do_list(F+1, T, Acc);
do_list(_F, <<>>, Acc) -> lists:reverse(Acc).


append_list([H|T], Mask) ->
    append_list(T, insert(H, Mask));

append_list([], Mask) -> Mask.


bits(#bitmask{bin=B}) ->
    do_bits(B, []).

do_bits(<<H:1, T/bitstring>>, Acc) -> do_bits(T, [H|Acc]);
do_bits(<<>>, Acc) -> lists:reverse(Acc).

