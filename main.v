module main

import time
import rand
import rpi_gpio
/* #flag -O3 */


fn number_conversor(index int) []int {
        array_number := [[0, 0, 0, 0, 0, 0, 1, 1], [0, 0, 0, 1, 0, 0, 1, 1],
        [0, 0, 1, 0, 0, 0, 1, 1], [0, 0, 1, 1, 0, 0, 1, 1],
        [0, 1, 0, 0, 0, 0, 1, 1], [0, 1, 0, 1, 0, 0, 1, 1],
        [0, 1, 1, 1, 0, 0, 1, 1], [0, 1, 1, 1, 0, 0, 1, 1],
        [1, 0, 0, 0, 0, 0, 1, 1], [1, 0, 0, 1, 0, 0, 1, 1]]/* each position means the number on hexadecimal */

        return array_number[index]
}

fn print_number(number int, lcd mut rpi_gpio.Lcd) {
        if number <= 9 {
                array := number_conversor(number)
                lcd.instruction_4bit(1, 0, array[0], array[1], array[2], array[3])/* MSB */

                lcd.instruction_4bit(1, 0, array[4], array[5], array[6], array[7])/* LSB */

        }
        else {
                temp_string := number.str()
                cut_1 := temp_string[0..temp_string.len - 1]/* get the first number */

                cut_2 := temp_string[1..temp_string.len]/* get the last number */

                mut array := number_conversor(cut_1.int())
                lcd.instruction_4bit(1, 0, array[0], array[1], array[2], array[3])/* MSB */

                lcd.instruction_4bit(1, 0, array[4], array[5], array[6], array[7])/* LSB */

                lcd.shift_cursor(1)/* move to right */

                array = number_conversor(cut_2.int())
                lcd.instruction_4bit(1, 0, array[0], array[1], array[2], array[3])/* MSB */

                lcd.instruction_4bit(1, 0, array[4], array[5], array[6], array[7])/* LSB */

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
        return rand.next(3) + 1
}

fn draw_block(lcd mut rpi_gpio.Lcd, size int, start_location int) {
        lcd.home_cursor()
        lcd.shift_cursor(0)
        for counter := 0; counter < start_location; counter++ {
                lcd.shift_cursor(0)
        }
        for counter := 0; counter <= size; counter++ {
                lcd.instruction_4bit(1, 0, 1, 1, 1, 1)
                lcd.instruction_4bit(1, 0, 1, 1, 1, 1)
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
                        println('counter: $counter')
                }
                state = current_state
                time.sleep_ms(10)
        }
}

fn initialize_lcd(gpio mut rpi_gpio.Gpio) rpi_gpio.Lcd {
        mut lcd := rpi_gpio.Lcd{}
        lcd.export_default(mut gpio)
        ticks := time.ticks()
        println('Initializing...')
        lcd.initialize_4bit()
        println('Initialized after ${time.ticks() - ticks}')
        return lcd
}

fn create_character(lcd mut rpi_gpio.Lcd) {
        /*WALKING */

        /*Addres Code - 40 */
        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 0, 0, 0, 0)
        /*Draw first line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 1, 1, 0)
        /*Addres Code - 41 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 0, 0, 0, 1)
        /*Draw second line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 1, 1, 0)
        /*Addres Code - 42 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 0, 0, 1, 0)
        /*Draw third line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        /*Addres Code - 43 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 0, 0, 1, 1)
        /*Draw forth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 1, 0, 0)
        /*Addres Code - 44 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        /*Draw fifth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 0)
        /*Addres Code - 45 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 1, 0, 0, 1)
        /*Draw sixth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
        /*Addres Code - 46 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 0, 1, 1, 0)
        /*Draw seventh line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 1)
        lcd.instruction_4bit(1, 0, 1, 0, 1, 0)
        /*Addres Code - 47 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 0, 1, 1, 1)
        /*Draw eighth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 1)
        lcd.instruction_4bit(1, 0, 1, 0, 1, 0)
        /*Jumping */

        /*Addres Code - 48 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 1, 0, 0, 0)
        /*Draw first line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 1, 1, 0)
        /*Addres Code - 49 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(0, 0, 1, 0, 0, 1)
        /*Draw second line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 1, 1, 0)
        /*Addres Code - 50 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 0, 0, 0, 0)
        /*Draw third line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        /*Addres Code - 51 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 0, 0, 0, 1)
        /*Draw forth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 1, 1, 0)
        /*Addres Code - 52 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 0, 0, 1, 0)
        /*Draw fifth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
        /*Addres Code - 53 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 0, 0, 1, 1)
        /*Draw sixth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        /*Addres Code - 54 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 0, 1, 0, 0)
        /*Draw seventh line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 0, 1, 0)
        /*Addres Code - 55 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        /*Draw eighth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        /*WALKING 2 */

        /*Addres Code - 56 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 0, 1, 1, 0)
        /*Draw first line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 1, 1, 0)
        /*Addres Code - 57 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 0, 1, 1, 1)
        /*Draw second line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 1, 1, 0)
        /*Addres Code - 58 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 1, 0, 0, 0)
        /*Draw third line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        /*Addres Code - 59 */

        lcd.instruction_4bit(0, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(0, 0, 1, 0, 0, 1)
        /*Draw forth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 0)
        /*Addres Code - 60 */

        lcd.instruction_4bit(0, 0, 0, 1, 1, 0)
        lcd.instruction_4bit(0, 0, 0, 0, 0, 0)
        /*Draw fifth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 0)
        /*Addres Code - 61 */

        lcd.instruction_4bit(0, 0, 0, 1, 1, 0)
        lcd.instruction_4bit(0, 0, 0, 0, 0, 1)
        /*Draw sixth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        /*Addres Code - 62 */

        lcd.instruction_4bit(0, 0, 0, 1, 1, 0)
        lcd.instruction_4bit(0, 0, 0, 0, 1, 0)
        /*Draw seventh line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 1, 0, 1, 0)
        /*Addres Code - 63 */

        lcd.instruction_4bit(0, 0, 0, 1, 1, 0)
        lcd.instruction_4bit(0, 0, 0, 0, 1, 1)
        /*Draw eighth line for CGRAM */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 1)
        lcd.instruction_4bit(1, 0, 0, 0, 1, 0)
}

fn press_start(lcd mut rpi_gpio.Lcd) {
        lcd.clear_display()
        lcd.home_cursor()
        /* Write P */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
        time.usleep(3000)
        lcd.shift_cursor(1)
        /* Write R */

        lcd.instruction_4bit(1, 0, 0, 0, 1, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        time.usleep(3000)
        lcd.shift_cursor(1)
        /* Write E */

        lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 0)
        time.usleep(3000)
        lcd.shift_cursor(1)
        /* Write S */

        lcd.instruction_4bit(1, 0, 0, 0, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        time.usleep(3000)
        lcd.shift_cursor(1)
        /* Write S */

        lcd.instruction_4bit(1, 0, 0, 0, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        time.usleep(3000)
        lcd.shift_cursor(1)
        lcd.shift_cursor(1)/* White Space */

        /* Write S */

        lcd.instruction_4bit(1, 0, 0, 0, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
        time.usleep(3000)
        /* Write T */

        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        time.usleep(3000)
        /* Write A */

        lcd.instruction_4bit(1, 0, 0, 0, 0, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 0)
        time.usleep(3000)
        /* Write R */

        lcd.instruction_4bit(1, 0, 0, 0, 1, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        time.usleep(3000)
        /* Write T */

        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        time.usleep(3000)
}

fn main() {
        mut gpio := rpi_gpio.Gpio{}
        mut lcd := initialize_lcd(mut gpio)
        create_character(mut lcd)
        mut initialized := gpio.export_pin('24')
        initialized = initialized && gpio.export_pin('23')
        println('Exported pin 24 && 23: ${initialized}')
        time.sleep_ms(5)
        mut gpio_24 := gpio.get_pin('24')
        mut gpio_23 := gpio.get_pin('23')
        gpio_24.set_direction(true)
        gpio_23.set_direction(true)
        mut previous_tick := time.ticks()
        mut score := 0
        mut player_y := false
        mut time_in_air := time.ticks()
        mut blocks_position := 0
        mut blocks_size := generate_block()
        mut game_state := 0
        for {
                if game_state == 0 {
                        press_start(mut lcd)
                        if gpio_23.read() == 1 {
                                game_state = 1
                        }
                }
                else if game_state == 1 {
                        if score_counter(previous_tick) {
                                score++
                                previous_tick = time.ticks()
                                println(score)
                                blocks_position++
                        }
                        if gpio_24.read() == 1 {
                                player_y = true/* still needs verify gravity */

                                time_in_air = time.ticks()
                        }
                        if player_y && time.ticks() - time_in_air > 140 {
                                /* gravity */
                                time_in_air = 0
                                player_y = false
                        }
                        if blocks_position >= 16 + blocks_size {
                                blocks_position = 0
                                blocks_size = generate_block()
                        }
                        if blocks_position == 14 && !player_y {
                                game_state = 2
                        }
                        else {
                                /* main game logic */
                                lcd.clear_display()
                                draw_block(mut lcd, blocks_size, blocks_position)
                        }
                }
                else if game_state == 2 {
                        if gpio_23.read() == 1 {
                                game_state = 1
                        }
                }
        }
}
