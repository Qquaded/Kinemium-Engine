#include <iostream>
#define PI 3.14159

const int maxValue = 10;

struct Vector2 {
    float x = 0;
    float y = 0;
};

int add(int a, int b) {
    return a + b;
}

int main() {
    int sum = 0;
    Vector2 pos;
    int values[5] = {1, 2, 3, 4, 5};

    for(int i = 0; i < maxValue; i++) {
        sum += i;
    }

    bool isActive = true;
    if(!isActive || sum != 0) {
        sum = add(sum, 5);
    }

    std::vector<int> list;
    list.push_back(sum);

    int a = 1, b = 2;
    a <<= 1;
    b |= 3;

    return 0;
}
