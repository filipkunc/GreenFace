//
//  Shader.fsh
//  Test
//
//  Created by Filip Kunc on 12/4/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
