import { Router } from "express"
import { registerUser } from "../controller/_01_user.controller.js"

const userRouter=Router()


userRouter
.route( '/register').post(registerUser)


   

export {userRouter}