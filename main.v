module main

import time
import rpi_gpio

fn main() {
	mut gpio := rpi_gpio.Gpio{}
	if gpio.export_pin("24") {
		time.sleep(5)
		mut gpio_24 := gpio.get_pin("24")
		gpio_24.set_direction(false)
		time.sleep(5)
		for {
			println(gpio_24.read())
			time.sleep(5)
		}
	}
}
