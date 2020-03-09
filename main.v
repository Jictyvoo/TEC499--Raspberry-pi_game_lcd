module main

import time
import rand
import rpi_gpio
/* #flag -O3 */


fn number_conversor(index int) []int {
        array_number := [
                [0, 0, 1, 1, 0, 0, 0, 0], [0, 0, 1, 1, 0, 0, 0, 1],
                [0, 0, 1, 1, 0, 0, 1, 0], [0, 0, 1, 1, 0, 0, 1, 1],
                [0, 0, 1, 1, 0, 1, 0, 0], [0, 0, 1, 1, 0, 1, 0, 1],
                [0, 0, 1, 1, 0, 1, 1, 1], [0, 0, 1, 1, 0, 1, 1, 1],
                [0, 0, 1, 1, 1, 0, 0, 0], [0, 0, 1, 1, 1, 0, 0, 1]
        ]/* each position means the number on hexadecimal */

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
        return rand.next(3) + 3
}

fn draw_character(lcd mut rpi_gpio.Lcd, player_y bool, change_sprite bool) {
        lcd.home_cursor()
        //println('Draw Character')
        /* se estiver no solo, player_y e negado */
        if !player_y {
                /* mover para terceira casa da linha debaixo */
                for counter := 0; counter < 44; counter++ {
                        lcd.shift_cursor(1)
                }
                /* seleciona o char do movimento */
                if change_sprite {
                        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
                        lcd.instruction_4bit(1, 0, 0, 0, 0, 0) /* CGRAM 1 */
                }
                else {
                        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
                        lcd.instruction_4bit(1, 0, 0, 0, 1, 0) /* CGRAM 3 */
                }
        }
        else {
                for counter := 0; counter < 4; counter++ {
                        lcd.shift_cursor(1)
                }
                lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
                lcd.instruction_4bit(1, 0, 0, 0, 0, 1) /* CGRAM 2 */
        }
}

fn draw_block(lcd mut rpi_gpio.Lcd, size int, start_location int) {
        lcd.home_cursor()
        //println('Draw Block')
        /*lcd.instruction_4bit(0, 0, 0, 0, 0, 0)
        lcd.instruction_4bit(0, 0, 1, 1, 1, 1) Draw Cursor*/
        for counter := 0; counter < 56; counter++{
                lcd.shift_cursor(1)
        }
        lcd.instruction_4bit(1, 0, 1, 1, 1, 1)
        lcd.instruction_4bit(1, 0, 1, 1, 1, 1)
        
        for counter := 0; counter < start_location; counter++ {
                lcd.shift_cursor(0)
        }
        for counter := 0; counter <= size; counter++ {
                lcd.instruction_4bit(1, 0, 1, 1, 1, 1)
                lcd.instruction_4bit(1, 0, 1, 1, 1, 1)
                /*lcd.shift_cursor(0)*/
        }
}

fn always_read(gpio_pin rpi_gpio.Pin, name string) {
        mut counter := 0
        mut state := 0
        mut current_state := 0
        for {
                current_state = gpio_pin.read()
                if current_state == 1 && current_state != state {
                        counter++
                        println('gpio_$name counter: $counter')
                }
                state = current_state
                time.sleep_ms(10)
        }
}

fn draw_score(score int, lcd mut rpi_gpio.Lcd) {
        //println("Drawing Score")
        lcd.home_cursor()
        for counter := 0; counter < 14; counter++ {
                lcd.shift_cursor(1)
        }
        print_number(score, mut lcd)
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
        //println("Press Start")
        lcd.clear_display()
        lcd.home_cursor()
        /* Write P */
        lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(1, 0, 0, 0, 0, 0)
        time.usleep(3000)
        /* Write R */

        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 0, 1, 0)
        time.usleep(3000)
        /* Write E */

        lcd.instruction_4bit(1, 0, 0, 1, 1, 0)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
        time.usleep(3000)
        /* Write S */

        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 0, 1, 1)
        time.usleep(3000)
        /* Write S */

        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 0, 1, 1)
        time.usleep(3000)
        lcd.shift_cursor(1)/* White Space */

        /* Write S */

        lcd.instruction_4bit(1, 0, 0, 1, 0, 1)
        lcd.instruction_4bit(1, 0, 0, 0, 1, 1)
        time.usleep(3000)
        /* Write T */

        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        time.usleep(3000)
        /* Write A */

        lcd.instruction_4bit(1, 0, 0, 1, 1, 0)
        lcd.instruction_4bit(1, 0, 0, 0, 0, 1)
        time.usleep(3000)
        /* Write R */

        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 0, 1, 0)
        time.usleep(3000)
        /* Write T */

        lcd.instruction_4bit(1, 0, 0, 1, 1, 1)
        lcd.instruction_4bit(1, 0, 0, 1, 0, 0)
        time.usleep(3000)
}

fn main() {
        mut gpio := rpi_gpio.Gpio{}
        mut lcd := initialize_lcd(mut gpio)
        create_character(mut lcd)
        mut initialized := gpio.export_pin('26')
        initialized = initialized && gpio.export_pin('19')
        initialized = initialized && gpio.export_pin('5')
        println('Exported pin 26 && 19 && 5: ${initialized}')
        time.sleep_ms(5)
        mut gpio_26 := gpio.get_pin('26')
        mut gpio_19 := gpio.get_pin('19')
        mut gpio_5 := gpio.get_pin('5')
        gpio_19.set_direction(true)
        gpio_26.set_direction(true)
        gpio_5.set_direction(true)
        //go always_read(gpio_5, '5')
        go always_read(gpio_19, '19')
        go always_read(gpio_26, '26')
        gpio_26.set_direction(true)
        gpio_19.set_direction(true)
        mut previous_tick := time.ticks()
        mut score := 0
        mut player_y := false
        mut time_in_air := time.ticks()
        mut blocks_position := 0
        mut blocks_size := generate_block()
        mut game_state := 0
        mut change_sprite := false
        mut temp_int := 0
        mut temp_bool := false
        mut paused := false
        mut pause_pressed := false
        for {
                if game_state == 0 {
                        if score_counter(previous_tick) {
                                temp_int++
                                previous_tick = time.ticks()
                        }
                        if temp_int >= 3 {
                                if temp_bool {
                                        press_start(mut lcd)
                                } else {
                                        lcd.clear_display()
                                }
                                temp_int = 0
                                temp_bool = !temp_bool
                        }
                        if gpio_5.read() == 0 {
                                game_state = 1
                        }
                }
                else if game_state == 1 {
                        temp_bool = gpio_19.read() == 0
                        if temp_bool && temp_bool != pause_pressed {
                                paused = !paused
                        }
                        pause_pressed = temp_bool
                        if !paused {
                                if score_counter(previous_tick) {
                                        score++
                                        if score > 99 {
                                                score = 0
                                        }
                                        previous_tick = time.ticks()
                                        blocks_position++
                                        change_sprite = !change_sprite
                                }
                                if gpio_5.read() == 0 {
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
                                        game_state = 0
                                        score = 0
                                }
                        }
                        /* main game logic */
                        lcd.clear_display()
                        draw_score(score, mut lcd)
                        draw_character(mut lcd, player_y, change_sprite)
                        draw_block(mut lcd, blocks_size, blocks_position)
                        time.sleep_ms(300)
                }
                else if game_state == 2 {
                        if gpio_5.read() == 0 {
                                game_state = 1
                        }
                }
        }
}
