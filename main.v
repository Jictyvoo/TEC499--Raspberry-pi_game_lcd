module main

import time
import rand
import rpi_gpio

//#flag -O3

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
	for {

	}
}
