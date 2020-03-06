module main

import time
import rand
import rpi_gpio

//#flag -O3

fn number_conversor(index int) []int {
    array_number := [[0,0,0,0,0,0,1,1], [0,0,0,1,0,0,1,1], 
                     [0,0,1,0,0,0,1,1], [0,0,1,1,0,0,1,1],
                     [0,1,0,0,0,0,1,1], [0,1,0,1,0,0,1,1],
                     [0,1,1,1,0,0,1,1], [0,1,1,1,0,0,1,1],
                     [1,0,0,0,0,0,1,1], [1,0,0,1,0,0,1,1]]//each position means the number on hexadecimal

    return array_number[index]
}

fn print_number(number int, lcd mut rpi_gpio.Lcd){
    if number <= 9 {
        array := number_conversor(number)
        lcd.instruction_4bit(1, 0, array[0], array[1], array[2], array[3])//MSB
        lcd.instruction_4bit(1, 0, array[4], array[5], array[6], array[7])//LSB
    } else{
		temp_string := number.str()
        cut_1 := temp_string[0..temp_string.len - 1] //get the first number
        cut_2 := temp_string[1..temp_string.len]     //get the last number

        mut array := number_conversor(cut_1.int())
        lcd.instruction_4bit(1, 0, array[0], array[1], array[2], array[3])//MSB
        lcd.instruction_4bit(1, 0, array[4], array[5], array[6], array[7])//LSB

        lcd.shift_cursor(1)//move to right

        array = number_conversor(cut_2.int())
        lcd.instruction_4bit(1, 0, array[0], array[1], array[2], array[3])//MSB
        lcd.instruction_4bit(1, 0, array[4], array[5], array[6], array[7])//LSB
    }
}

fn score_counter(previous_tick i64) bool {
	if (time.ticks() - previous_tick) >= 400 {
		return true
	}
	return false
}

fn generate_block() int {
	rand.seed(int(time.ticks()))
	return rand.next(3)
}

fn draw_block(lcd mut rpi_gpio.Lcd, size int, start_location int) {
	lcd.clear_display()
	lcd.home_cursor()
	lcd.shift_cursor(0)
	for counter := 0; counter < start_location; counter++ {
		lcd.shift_cursor(0)
	}
	for counter := 0; counter <= size; counter++ {
		lcd.instruction_4bit(1,0,1,1,1,1)
    	lcd.instruction_4bit(1,0,1,1,1,1)
		lcd.shift_cursor(0)
	}
}

fn always_read(gpio_23 rpi_gpio.Pin) {
	mut counter := 0
	mut state := 0
	mut current_state := 0
	for {
		current_state = gpio_23.read()
		if current_state == 1 && current_state != state {
			counter++
			println("counter: $counter")
		}
		state = current_state
		time.sleep_ms(10)
	}
}

fn initialize_lcd(gpio mut rpi_gpio.Gpio) {
	mut lcd := rpi_gpio.Lcd{}
	lcd.export_default(mut gpio)
	ticks := time.ticks()
	println("Initializing...")
	lcd.initialize_4bit()
	println("Initialized after ${time.ticks() - ticks}")
}

fn press_start(lcd mut rpi_gpio.Lcd) {
	lcd.clear_display()
	lcd.home_cursor()

	// Write P
	lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
    lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
	time.usleep(3000)
	lcd.shift_cursor(1)
	// Write R
	lcd.instruction_4bit(1, 0, 0, 0, 1, 0)
    lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
	time.usleep(3000)
	lcd.shift_cursor(1)
	// Write E
	lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
    lcd.instruction_4bit(1, 0, 0, 1, 1, 0)
	time.usleep(3000)
	lcd.shift_cursor(1)
	// Write S
	lcd.instruction_4bit(1, 0, 0, 0, 1, 1)
    lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
	time.usleep(3000)
	lcd.shift_cursor(1)
	// Write S
	lcd.instruction_4bit(1, 0, 0, 0, 1, 1)
    lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
	time.usleep(3000)
	lcd.shift_cursor(1)
}

fn main() {
	mut gpio := rpi_gpio.Gpio{}
	initialize_lcd(mut gpio)
	mut initialized := gpio.export_pin("24")
	initialized = initialized && gpio.export_pin("23")
	println("Exported pin 24 && 23: ${initialized}")
	time.sleep_ms(5)
	mut gpio_24 := gpio.get_pin("24")
	mut gpio_23 := gpio.get_pin("23")
	gpio_24.set_direction(false)
	gpio_23.set_direction(true)
	mut previous_tick := time.ticks()
	mut score := 0
	for {
		if score_counter(previous_tick) {
			score++
			previous_tick = time.ticks()
			println(score)
		}
	}
}
