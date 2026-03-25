import math
def get_function():
    while True:
        func_str=input("enter a function of x:")
        try:
            x=1
            eval(func_str,{"x":x,"math":math})
            break
        except Exception as e:
            print("invalid function")
    return lambda x:eval(func_str,{"x":x,"math":math})
def bisection(f,a,b,tol=1e-6,max_iter=100):
    if f(a)*f(b)>=0:
        print("error:f(a) and f(b)should have opposite sighns")
        return None
    print(f"{'iteration':<10}{'a':<15}{'b':<15}{'c':<15}{'f(c)':<15}")
    iter_count=0
    while(b-a)/2>tol and iter_count<max_iter:
        c=(a+b)/2
        print(f"iteration{iter_count}:a={a},b={b},c={c}f(c)={f(c)}")
        if f(c)==0:
            break
        elif f(a)*f(c)<0:
            b=c
        else:
            a=c
            iter_count+=1
            root=(a+b)/2
            print(f"approximate root:{root}")
print("bisection method solver")
f=get_function()
try:
    a=float(input("enter the lower interval a: "))
    b=float(input("enter the upper interval b: "))
except ValueError:
    print ("invalid input,please enter numbers only")
    exit()
tol_input=input("enter tolerance(default 1e-6): ")
tol=float(tol_input)if tol_input else 1e-6
max_iter_input=input("enter maximum iterations(default 50): ")
max_iter=int(max_iter_input)if max_iter_input else 5
root=bisection(f,a,b,tol,max_iter)
if root is not None:
    print(f"\napproximate root not found")
else:
    print("bisection method could not find a root")

