import random

def bht_classical(f, n, k):
    # repeat the algorithm k times
    for i in range(k):
        # Step 1: Prepare uniform superposition over all possible inputs
        input_register = [random.randint(0, 1) for i in range(n)]
        output_register = [0 for i in range(n)]

        # Step 2: Apply the oracle that marks the collision(s)
        collision_available = False
        for j in range(2**n):
            input_str = "".join(str(x) for x in input_register)
            if f(input_str) == 1:
                if collision_available:
                    # A second collision was found; terminate the algorithm
                    return input_register
                else:
                    # A collision was found; mark the output qubit and continue
                    output_register = [
                        1 if x == 0 else 0 for x in output_register]
                    collision_available = True
            # increment the input register
            for k in range(n-1, -1, -1):
                if input_register[k] == 0:
                    input_register[k] = 1
                    break
                else:
                    input_register[k] = 0

        # Step 3: Apply the Grover diffusion operator
        input_register = [2*x-1 for x in input_register]

        mean = sum(input_register) / len(input_register)

        input_register = [(x - mean) * -1 for x in input_register]

        input_register = [(x + 1) / 2 for x in input_register]
        
        input_register = [1 - 2*x for x in input_register]

    # If no collisions were found after k iterations, return None
    return None

# Define the function f for which we want to find collisions


def f(input_str):
    num_ones = input_str.count('1')
    if num_ones % 2 == 1:
        return 1
    else:
        return 0


# Call the bht_classical function with f, n=3, and k=1
result = bht_classical(f, 5, 2)

# Print the result
if result is not None:
    print("Collision found! Input string: ", result)
else:
    print("No collision found after 1 iteration.")