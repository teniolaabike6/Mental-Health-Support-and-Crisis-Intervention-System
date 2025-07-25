# Mental Health Support and Crisis Intervention System

A comprehensive blockchain-based mental health support system built on Stacks using Clarity smart contracts. This system provides automated screening, crisis intervention coordination, therapy scheduling, peer support facilitation, and stigma reduction initiatives.

## System Overview

The Mental Health Support System consists of five interconnected smart contracts:

### 1. Mental Health Screening Contract (`mental-health-screening.clar`)
- Automated mental health assessments
- Risk level categorization (low, moderate, high, crisis)
- Confidential screening results storage
- Integration with crisis intervention system

### 2. Crisis Hotline Coordination Contract (`crisis-hotline-coordination.clar`)
- 24/7 crisis intervention coordination
- Emergency response routing
- Crisis counselor availability tracking
- Immediate support resource allocation

### 3. Therapy Session Scheduling Contract (`therapy-session-scheduling.clar`)
- Therapist availability management
- Session booking and scheduling
- Treatment plan tracking
- Session outcome recording

### 4. Peer Support Group Facilitation Contract (`peer-support-groups.clar`)
- Support group creation and management
- Peer matching based on conditions/experiences
- Group session scheduling
- Anonymous participation options

### 5. Mental Health Stigma Reduction Contract (`stigma-reduction.clar`)
- Awareness campaign management
- Educational resource distribution
- Community engagement tracking
- Stigma reduction metrics

## Key Features

- **Privacy-First Design**: All personal health information is encrypted and access-controlled
- **Crisis Response**: Immediate routing to available crisis counselors
- **Automated Screening**: Regular mental health check-ins with risk assessment
- **Peer Support**: Matching individuals with similar experiences
- **Resource Allocation**: Efficient distribution of mental health resources
- **Stigma Reduction**: Community-driven awareness initiatives

## Data Privacy & Security

- All sensitive data is encrypted before storage
- Access controls ensure only authorized personnel can view personal information
- Anonymous participation options for peer support groups
- Compliance with mental health privacy regulations

## Contract Interactions

The contracts work together to provide a seamless mental health support experience:

1. **Screening → Crisis**: High-risk screenings automatically trigger crisis intervention
2. **Crisis → Therapy**: Crisis interventions can schedule follow-up therapy sessions
3. **Screening → Peer Support**: Moderate-risk individuals are matched with peer groups
4. **All Contracts → Stigma Reduction**: Successful interventions contribute to awareness metrics

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Stacks wallet for testing

### Installation

\`\`\`bash
git clone <repository-url>
cd mental-health-support-system
npm install
clarinet check
\`\`\`

### Running Tests

\`\`\`bash
npm test
\`\`\`

### Deployment

\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Usage Examples

### Conducting a Mental Health Screening
\`\`\`clarity
(contract-call? .mental-health-screening conduct-screening
u7 u6 u8 u5 u9)  ;; PHQ-9 scores
\`\`\`

### Requesting Crisis Support
\`\`\`clarity
(contract-call? .crisis-hotline-coordination request-crisis-support
"urgent" "suicidal ideation")
\`\`\`

### Scheduling Therapy Session
\`\`\`clarity
(contract-call? .therapy-session-scheduling book-session
"therapist-123" u1640995200)  ;; timestamp
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For technical support or questions about the mental health system:
- Create an issue in the repository
- Contact the development team
- Refer to the documentation

## Disclaimer

This system is designed to support mental health initiatives but should not replace professional medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers with questions about mental health conditions.
