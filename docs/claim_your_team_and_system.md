# Group 28 - BiCycure: a digital approach to frame numbers and theft resolution
========

## Group members
*   Wouter van den Boer - w.a.a.boer@student.tudelft.nl - @waaboer
*   Aayush Rajiv Shah - arshah@tudelft.nl - @arshah
*   Raghav Talwar - rtalwar@tudelft.nl - @rtalwar
*   Dimitris Ntatsis - d.ntatsis@student.tudelft.nl - @dntatsis

## Overview & Motivation
Traditionally, all bicycles in the Netherlands have a unique frame number. In case of theft, the frame number is used to link the bicycle to its rightful owner.

The Dutch government has developed an application named [stop heling](https://www.stopheling.nl/en/registreren). Using stop heling users can register their bicycle (and other possessions). In case of theft the user can report their bicycle as stolen.

This system can more effectively achieve its goal in four manners:

1.  more people store the unique identifier of their bicycles
2.  transfers of ownership should be (verifiably) stored
3.  in case of theft, more people report their bicycle as stolen
4.  More bicycles are scanned and looked up in the database of stolen bicycles

We aim to design a system which uses digital technology to uniquely identify bicycles such that the process of scanning the identifier is sped up. Solutions to be explored are embedded RFID tags and engraved bar codes in the frame. These should be reliable, not require any charging and last for decades. We aim to let people identify a stolen bicycle just by scanning the embedded RFID tags on their phones through the app. In addition to this, our platform would empower the bereaved to launch monetary rewards for their stolen bicycles, in which citizens or businesses can participate for a reward decided by the rightful owner.

Special architectural challenges are as follows:

*   *privacy*: it should not be possible to track anyone based on where their bicycles is spotted. Neither should it be possible to know who owns what products (unless it is reported as stolen).
*   *ease of use*: the system should be easy to use for all parties in order to (amongst other goals) improve on the four points mentioned above. The target audience is very broad and hence the design should reflect this.

Important stakeholders to be considered:

*   bicycle owners
*   law enforcement
*   regulators
*   bicycle manufacturers


