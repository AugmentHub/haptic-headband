void setup() {
  Serial.begin(9600);

  pinMode(A2, OUTPUT);
  pinMode(A1, OUTPUT);
  pinMode(A4, OUTPUT);
  pinMode(A5, OUTPUT);
  pinMode(A3, OUTPUT);
  
  // Set the data direction register for PORTF pins to output
  DDRF |= (1 << DDF6) | (1 << DDF5) | (1 << DDF4) | (1 << DDF1) | (1 << DDF0);
}

int a = 4;
int b = 0;
int c = 500;
unsigned long previousMillis = 0;
const long interval = 5;

void loop() {
  if (Serial.available() > 0) {
    // Read the input string
    String input = Serial.readStringUntil('\n');
    if (input.startsWith("spin")) {
      for(int i = 0; i < 16; i++) {
        run_motor(i, c, b);
      }
    }

    if (input.startsWith("spin2")) {
      for(int i = 0; i < 16; i++) {
        run_motor(i, c, b + abs(8-i)*20);
      }
    }

    if (input.startsWith("unspin")) {
      for(int i = 0; i < 16; i++) {
        run_motor(i, c, b + (8-abs(i-8))*20);
      }
    }

    // Check if the input starts with "pulse"
    if (input.startsWith("pulse")) {
      // Remove the "pulse" part
      input.remove(0, 6);

      // Parse the remaining part of the string for three numbers
      int index1 = input.indexOf(' ');
      int index2 = input.indexOf(' ', index1 + 1);

      if (index1 != -1 && index2 != -1) {
        a = input.substring(0, index1).toInt();
        b = input.substring(index1 + 1, index2).toInt();
        c = input.substring(index2 + 1).toInt();

        // Print the numbers to verify
        Serial.print("a: ");
        Serial.println(a);
        Serial.print("b: ");
        Serial.println(b);
        Serial.print("c: ");
        Serial.println(c);

        // Call your function or use the numbers as needed
        // Example: run_motor(a, c, b);
      } else {
        Serial.println("Invalid command format. Use: pulse a b c");
      }
    } else {
      Serial.println("Unknown command. Use: pulse a b c");
    }
  }

  
  int t = millis() % (c + b);
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= 15) {
    previousMillis = currentMillis;
    run_motor_async_reg(a, c, b, t);
  }
  
}

void run_motor_async_reg(int motor_index, int time_on, int time_off, int t_in) {
  int T = time_on + time_off;
  int t = t_in % T;

  // Set A5 (digital pin 25) using PORTF6
  if (motor_index & 0b0010) {
    PORTF |= (1 << PORTF6);
  } else {
    PORTF &= ~(1 << PORTF6);
  }

  // Set A4 (digital pin 24) using PORTF5
  if (motor_index & 0b0001) {
    PORTF |= (1 << PORTF5);
  } else {
    PORTF &= ~(1 << PORTF5);
  }

  // Set A1 (digital pin 21) using PORTF1
  if (motor_index & 0b0100) {
    PORTF |= (1 << PORTF1);
  } else {
    PORTF &= ~(1 << PORTF1);
  }

  // Set A2 (digital pin 22) using PORTF0
  if (motor_index & 0b1000) {
    PORTF |= (1 << PORTF0);
  } else {
    PORTF &= ~(1 << PORTF0);
  }

  // Set A3 (digital pin 23) using PORTF4
  if (t < time_on) {
    PORTF |= (1 << PORTF4);
  } else {
    PORTF &= ~(1 << PORTF4);
  }
}

void run_motor_async(int motor_index, int time_on, int time_off, int t_in) {
  int T = time_on + time_off;
  int t = t_in % T;
  digitalWrite(A5, (motor_index & 0b1000) >> 3);
  digitalWrite(A4, (motor_index & 0b0100) >> 2);
  digitalWrite(A1, (motor_index & 0b0010) >> 1);
  digitalWrite(A2, (motor_index & 0b0001));
  if (t < time_on) {
    digitalWrite(A3, HIGH);
  } else {
    digitalWrite(A3, LOW);
  }
}

void run_motor(int motor_index, int time_on, int time_off) {
  digitalWrite(A5, (motor_index & 0b1000) >> 3);
  digitalWrite(A4, (motor_index & 0b0100) >> 2);
  digitalWrite(A1, (motor_index & 0b0010) >> 1);
  digitalWrite(A2, (motor_index & 0b0001));

  digitalWrite(A3, HIGH);
  delay(time_on);

  digitalWrite(A3, LOW);
  delay(time_off);
}
