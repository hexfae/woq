use iced::{
    Result,
    widget::{Column, button, column},
};

#[derive(Default)]
struct Browser;

#[derive(Clone)]
enum Message {
    Click,
}

impl Browser {
    #[expect(clippy::unused_self)]
    fn update(&mut self, _message: Message) {
        println!("clicked :)");
    }

    #[expect(clippy::unused_self)]
    fn view(&self) -> Column<'_, Message> {
        let button = button("hi").on_press(Message::Click);
        column![button]
    }
}

fn main() -> Result {
    iced::run(Browser::update, Browser::view)
}
