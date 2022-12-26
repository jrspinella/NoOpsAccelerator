# What is NoOps? - Shift focus from Operational Overhead to Mission Outcomes using the Azure NoOps Accelerator

I am sure you’ve heard the adage about NoOps. They are coming for my operations job, or they don't need us anymore. To be clear, NoOps, in my context, is not the same as outsourcing your IT operations or looking to replace you. That is far from the truth when I talk about NoOps.

The phrase "NoOps" originated with a mission customer I was working with who was seeking Mission Landing Zone (MLZ) deployment simplicity with valuable workloads to have greater deployment flexibility and required reduced O&M due to small staff size. To enable "NoOps," or "No Operational Overhead," as they called it, they asked for the ability to "hyper-automate" their Azure footprint and governance.

“No Operational Overhead,” which is a significant assertion in this situation. An environment that lowers operational overhead; instills the belief that environments can be automated to a point, thus eliminating human handoffs and low-value, routine administration.

This idea has turned the focus on what I believe a NoOps environment can be. To have smaller teams to get more things done, move at a faster pace, and do that in a highly resilient manner by encouraging a more mission-oriented emphasis to swiftly deliver capabilities to the warfighter through a rapid development and deployment process.

In this article, I talk about the movement of NoOps in my context with my customer and how to reach an attainable state with the Azure NoOps Accelerator (https://aka.ms/azurenoops).

## Is NoOps the same as DevOps?

I always get asked this question. My answer is “Kind of”

Let's review the definition of DevOps first, then examine what NoOps is. DevOps is a collaboration between the development and operations teams that aims to accelerate delivery cycles, foster continuous innovation, and raise the caliber of software output. The success of DevOps greatly depends on the synergy between your development and operations teams, as it brings together system administrators and developers who would otherwise work in silos.

![DevOps-NoOps](./media/devops-noops.png)

However, NoOps, or "No Operational Overhead," is a relatively new idea. Organizations must strive to automate platform operations which encourages the staff to focus on other projects and deployment tasks that support the mission. It can be inferred that DevOps does not have an end goal and is a continuous process. In my mind, NoOps has a definitive goal, i.e., **to automate every aspect of platform administration and broaden communication between developers, cyber, and operations to achieve mission success.**

## Building a NoOps Culture

The purpose of NoOps is to define a process to automate every aspect of platform administration and broaden communication between developers, cyber, and operations. To do this, there are things you would need to think about when building a Successful NoOps Culture.

### DevOps Mindset

NoOps adoption does not happen overnight. Your team must receive adequate training to understand how their roles and daily tasks will change. Establishing a work environment and culture where automation takes precedence should be the primary goal of NoOps. And when the process and the people are in sync, the delivery of new services or apps can be accomplished much more quickly.

![2022-11-02_08-28-59](https://user-images.githubusercontent.com/5787207/199556654-061a593c-0d27-4f89-82c3-b77cfc0c08d6.jpg)

This also requires a culture shift. I try to instill the 3 C's of culture change:

- Coordinate - Coordinate all tasks in the development, cyber, and operations.
- Communicate - Increase communication between development, cyber, and operations.
- Continuously Improve - Drive improvements and changes to build up your NoOps Practice.

This method shifts the focus from silos to collaboration within the teams.

In the NoOps process, Cyber, Operations, and Development staff collaborate to create the "workload blocks" and write and maintain the Mission Enclave code (Infrastructure as Code) for their environment to customize and administer an Azure environment. To enable your team to learn and practice NoOps, you may need to change your current team structures and workflows and build habits.

### Shared Responsibility Model

NoOps is one of several end states. While DevOps is the process, NoOps integrates DevOps principles, one of them being the need to broaden communication of professionals in infrastructure, cybersecurity, and software development. What I refer to as the "Shared Responsibility Model."  

![image](https://user-images.githubusercontent.com/5787207/199557888-279fe61e-9220-409e-9e19-12178b169b54.png)

NoOps allows the collaboration of development, cyber, and operations experts to work together to meet the needs of the mission.  This allows operations and security to “shift left” with the developers by incorporating them into the development phase as early as possible. This will refocus environment buildout to a streamlined and uniform method on the platform administration development and deployment that could ease the burden of ATO (Authority to Operate).

Teams can then operate as a supporting function, providing developers with the knowledge and tools they need to work independently while maintaining the organization's necessary level of oversight.

#### What Does This Mean for cATO?

Clearly and simply securing the whole platform administration lifecycle, from design to production, shifting left, and automation, will give IT executives across the DOD, as well as their commercial partners, a significant advantage in their pursuit of cATO.

By implementing Cyber with Operations and Development as early as possible, we may prevent the deployment from happening with known vulnerabilities, which help lowers the risk, thus allowing Cyber to understand risk at an early level. Because of this, we can keep the cost of remediation to a minimum. Fixing operational and security flaws before going live is much less expensive than doing so after.

Even while the members of the development, cyber, and operations teams have distinct duties and responsibilities, it is the collaboration between these three teams that will make NoOps successful and speed up crucial outcomes to support mission success and the safety of warfighters.

### Policy-Driven Governance

Policy-driven governance is a core tenet of NoOps that requires the usage of Azure Policy to build and provide guardrails and to enable autonomy for the platform and application teams, regardless of their scale points.

The Shared Responsibility Model allows the cyber team to interact with development and operations to understand the policy bounds within the environment to decrease the operation and management overhead of maintaining compliance. 

Since ATO is driven by risk management, implementing policies prevents users from making changes within your Azure environment. Thus, reducing the risk that is imposed on your environment. 

## The Road to NoOps

NoOps and DevOps essentially try to achieve the same: improve the software deployment process and reduce the time for the warfighter. But while the collaboration between developers and the operations team was emphasized in DevOps, the focus is now workload development to deployment; both NoOps and DevOps approaches seek to improve the workload lifecycle.

### More automation, smaller teams

NoOps focuses on cloud services that are deployable by design without manual intervention. From infrastructure to management activities, the aim is to control everything using code, meaning every component should be deployed as part of the code and maintainable in the long run. NoOps eliminates the operational overhead required to support the cloud ecosystem for workloads.

### Shift from operations to mission results

NoOps also shifts the focus from operations to mission outcomes. Unlike DevOps, where the dev and ops teams work together to deliver value propositions to the customer, NoOps ideally eliminates any dependency on the operational overhead, reducing the time to get to the warfighter. Again, the focus is shifted to priority tasks that deliver value to warfighters—in other words, “fast beats slow.”

## Why use the Azure NoOps Accelerator?

When I built the Azure NoOps accelerator, in my mind, I wanted something that builds mission-capable enclaves that will deploy Mission Enclaves (landing zones and workloads) that are secure by default and conform to SCCA. I wanted the accelerator to help me **“create smart infrastructure with as little maintenance effort as possible and automate everything.”**

To do this, I had to drive deployment consistency through Infrastructure as Code (IaC). I use Azure Bicep because of the native support in Azure and allowing for the abstraction of Azure infrastructure. With this abstraction, I can build and automate modules with reduced overhead.

The most important part of the accelerator is that governance is a first-class citizen. This helps to ease the ATO burden and enables the evolution of a DevSecOps infrastructure which is a component of the Continuous ATO process.

Using automation tools enables development teams to accelerate their changes and deployment to enable smoother automation. When the NoOps model is adopted and used with the Azure NoOps Accelerator, services to responsibly deploy the required cloud components securely, including code and infrastructure. Managed cloud services, like PaaS or serverless, serve as the backbone of NoOps and leverage CI/CD as their core engine for deployment.

## Next Stop: NoOps

Whatever its form, NoOps allows organizations to adapt more rapidly and efficiently to changing mission needs. It also minimizes the cost of IT management. Automating routine IT operations tasks to free up expensive and limited people to concentrate on higher-value work like creating new services and apps for the warfighter.

It would be safer to say that NoOps is the evolution of DevOps, targeting a perfect end-state of automation efficiency. It allows organizations to redirect time, effort, and resources from operations to mission outcomes.

Like DevOps, NoOps is more about the shift in culture and process than technology. Organizations need to be intentional about this shift while staying grounded as to the practicalities of the transition.

Learn how the Azure NoOps Accelerator (https://aka.ms/azurenoops) can help your team achieve NoOps.
