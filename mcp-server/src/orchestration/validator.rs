use anyhow::Result;

pub struct NapValidator;

impl NapValidator {
    pub fn validate_risk_class(risk_class: i32) -> bool {
        risk_class >= 0 && risk_class <= 4
    }
    
    pub fn validate_autonomy_tier(tier: &str) -> bool {
        matches!(tier, "A0" | "A1" | "A2" | "A3" | "A4")
    }
}
