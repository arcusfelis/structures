```
> bitmask:new(10).
{bitmask,<<0,0:2>>,1,10}
> B1 = bitmask:new(10).
{bitmask,<<0,0:2>>,1,10}
> bitmask:append_list([1,2,3], B1).
{bitmask,<<224,0:2>>,1,10}
> B2 = bitmask:append_list([1,2,3], B1).
{bitmask,<<224,0:2>>,1,10}
> B3 = bitmask:append_list([3,6,8], B1).
{bitmask,<<37,0:2>>,1,10}
> bitmask:to_list(bitmask:union(B3, B2)).
[1,2,3,6,8]
> bitmask:to_list(bitmask:intersection(B3, B2)). 
[3]


> S2 = ordsets:from_list([1,2,3]).
[1,2,3]
> S3 = ordsets:from_list([3,6,8]).
[3,6,8]
> ordsets:intersection(S2, S3).
[3]
> ordsets:union(S2, S3).       
[1,2,3,6,8]

> ST = ordsets:from_list("test me now!").
" !emnostw"

> ordsets:intersection(lists:seq($a, $z), ST).
"emnostw"

> F = fun(X, Acc) -> 
    case ux_char:is_letter(X) of 
        true -> Acc+1; 
        false -> Acc 
    end 
end.
> ordsets:fold(F, 0, ordsets:from_list("test ми")).
5
```
