mod escrow;

pub mod mock {
    pub mod erc20;
}

#[cfg(test)]
mod tests {
    mod test_escrow;
    pub mod utils;
}
