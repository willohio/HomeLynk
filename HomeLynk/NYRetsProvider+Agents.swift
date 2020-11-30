//
//  NYRetsProvider+Agents.swift
//  HomeLynk
//
//  Created by William Santiago on 2/3/16.
//  Copyright © 2016 William Santiago. All rights reserved.
//

import Foundation
import SWXMLHash

extension NYRetsProvider
{
	private static let selectString = "AgentId,BizPhone,AgentEmail"
	
	class func getAgentsWithIds(
		ids: [Int],
		successHandler success:  ((agents: [HLAgent]) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?)
	{
		guard ids.count > 0
			else
		{
			log.error("Searching for 0 agents")
			failure?(requestError: RequestError.BadRequest("Trying to search for NY RETS agents with 0 agent ids"))
			return
		}
		
		var dqml = ""
		dqml += "("
		
		for id in ids
		{
			dqml += "(AgentId=\(id))|"
		}
		
		dqml = dqml.substringToIndex(dqml.endIndex.predecessor()) // Remove final pipe |
		dqml += ")"
		
		NYRetsSearchRequest.search(
			searchType: .Agent,
			dqmlString: dqml,
			selectString: selectString,
			startIndex: 0,
			successHandler: { (xml) -> () in
				if let countString = xml["RETS"]["COUNT"].element?.attributes["Records"], count = Int(countString) where count == 0
				{
					success?(agents: [HLAgent]())
				} else if let agents = getHLAgentsFromXML(xml)
				{
					success?(agents: agents)
				} else
				{
					if let text = xml.element?.text where text != ""
					{
						failure?(requestError: RequestError.BadResponseFormat(text))
					} else
					{
						failure?(requestError: RequestError.BadResponseFormat("Empty XML"))
					}
				}

			},
			failureHandler: { (requestError) -> () in
				failure?(requestError: requestError)
		})
		
	}
	
	class func getHLAgentsFromXML(xml: XMLIndexer) -> [HLAgent]?
	{
		guard let columnsString = xml["RETS"]["COLUMNS"].element?.text
		else
		{
			log.error("Missing columns in xml")
			return nil
		}
		
		let columnComponents = columnsString.componentsSeparatedByString("\t")

		var agents = [HLAgent]()
		
		for agentXML in xml["RETS"]["DATA"]
		{
			guard let agentString = agentXML.element?.text
				else
			{
				log.error("DATA element with no text")
				continue
			}
			
			var agentDictionary = [String : String]()
			let agentComponents = agentString.componentsSeparatedByString("\t")
			
			guard agentComponents.count == columnComponents.count
				else
			{
				log.error("Number of columns differs from number of property attributes")
				continue
			}
			
			for (index, columnName) in columnComponents.enumerate()
			{
				let propertyField = agentComponents[index]
				agentDictionary[columnName] = propertyField
			}
			
			guard let idString = agentDictionary["AgentId"], id = Int(idString) where id > 0
				else
			{
				log.error("No ID for agent")
				continue
			}
			
			guard let agentEmail = agentDictionary["AgentEmail"]
				else
			{
				log.error("No email for agent")
				continue
			}
			
			let agent = HLAgent(id: id)
			agent.email = agentEmail
			agents.append(agent)
		}
		
		return agents
	}
}
