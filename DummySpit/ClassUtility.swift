//
//  ClassUtility.swift
//  DummySpit
//
//  Created by Matthew Delves on 17/08/2014.
//  Copyright (c) 2014 Matthew Delves. All rights reserved.
//

import Foundation

// thanks to: http://stackoverflow.com/questions/24174510/how-to-create-a-class-array-in-swift
public class ClassUtility
{
  public class func classFromType<T: NSObject>(type: T.Type) -> AnyObject! {
    return T.valueForKey("self") //ask for class indirectly...
  }
}