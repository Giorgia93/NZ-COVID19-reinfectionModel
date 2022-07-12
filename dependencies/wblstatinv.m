function [a, b] = wblstatinv(m, v)


x0 = [m; m^2];
sTarg = [m; v];

options = optimoptions('fsolve','Display','off');
x = fsolve(@(x)myFn(x, sTarg), x0, options);
a = x(1);
b = x(2);

end



function f = myFn(x, sTarg)

[m, v] = wblstat(x(1), x(2));
f = [m; v] - sTarg;

end

