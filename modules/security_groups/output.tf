output "sg_ids" {
  value = tomap(
    {
      for sg in aws_security_group.dynamic : sg.tags.Name => sg.id
    }
  )
}
